#! /bin/sh
":"; exec emacs --quick --script "$0" -- "$@" # -*-emacs-lisp-*-

(defvar hyph-hack/vowels ;; (-flatten (first indian-dev-base-table))
  '(2309 2310 2366 2311 2367 2312 2368 2313 2369 2314 2370 2315 2371 2316 2402 2317 2373 2318 2374 2319 2375 2320 2376 2321 2377 2322 2378 2323 2379 2324 2380 2400 2372 2401 2403))

(defvar hyph-hack/long-word-regex
  ;; (rx-to-string '(>= 50 (syntax word)))
  "\\(?:\\sw\\{50,\\}\\)")

(defvar hyph-hack/vowels-iast-regex;; not complete
  ;; (regexp-opt (list "a" "ā" "i" "ī" "u" "ū" "ṛ" "ḷ"))
  "[aiuāīūḷṛ]")

(defvar hyph-hack/consonants ;; (butlasat (butlast (-flatten (second indian-dev-base-table))))
  '(2325 2326 2327 2328 2329 2330 2331 2332 2333 2334 2335 2336 2337 2338 2339 2340 2341 2342 2343 2344 2345 2346 2347 2348 2349 2350 2351 2352 2353 2354 2355 2356 2357 2358 2359 2360 2361 2392 2393 2394 2395 2396 2397 2398 2399))

(defvar hyph-hack/vowels-and-consonants (cons hyph-hack/vowels hyph-hack/consonants))

(defvar hyph-hack/virāma 2381)

(defvar hyph-hack/break-permitted 130)

(defun hyph-hack/devanāgarī-hyphenate-string (string &optional verify)
  "Insert character 130 (break permitted here) into STRING.

It effectively splits up unicode devanāgarī strings.  If VERIFY
is not nil, compare the results with the original string (if,
after removal of every character 130, it's the same, return it;
otherwise, raise an error).  Should ignore stuff other than
devanāgarī."
  (let ((src (append string nil))
	item results)
    (while src
      (setq item (pop src))
      (setq results
	    (if (and;; consonant or vowel preceded by a consonant --> allow break
		 (memq (car src) hyph-hack/consonants)
		 (memq item hyph-hack/vowels-and-consonants))
		(cons hyph-hack/break-permitted (cons item results))
	      (cons item results))))
    (if verify
      (if (string-equal (concat (delq hyph-hack/break-permitted (nreverse results)))
		   string)
	  (concat (nreverse results))
	(error "Lost some stuff here: %s vs %s" string
	       (concat (delq hyph-hack/break-permitted (nreverse results)))))
      (concat (nreverse results)))))

(defun hyph-hack/hyphenate-long-string (string)
  "Insert character 130 (break permitted here) into STRING.

This function tries to break suspiciously long words that LaTeX
might crash on.  To change length of string to work on, check
`hyph-hack/long-word-regex'.

See
http://tex.stackexchange.com/questions/294933/long-sanskrit-string-doesnt-get-hyphenated and 
the thread starting here http://tug.org/pipermail/xetex/2016-March/026542.html."
  (let ((end-of-match 1)
	(case-fold-search nil)
	results)
    (with-temp-buffer
      (insert string)
      (goto-char (point-min))
      (while (re-search-forward hyph-hack/long-word-regex nil t)
	(setq end-of-match (match-end 0))
	(goto-char (match-beginning 0))
	(while (re-search-forward hyph-hack/vowels-iast-regex end-of-match t)
	  (when (looking-at "\\w\\w")
	    (insert hyph-hack/break-permitted)
	    (setq end-of-match (+ end-of-match 1))))
	(goto-char end-of-match)
	(setq end-of-match nil))
      (buffer-substring-no-properties (point-min) (point-max)))))

(defun hyph-hack/hyphenate-region (start end &optional max-length interactive)
  "Hyphenate region from START to END, or whole buffer.

If called with prefix (C-u), ask for MAX-LENGTH of a string to separate on."
  (interactive
   (let ((max (if current-prefix-arg
		  (read-number "Separate after how many chars? " 50)
		50)))       
     (cond ((region-active-p) (list (region-beginning) (region-end) max 'interactive))
	   ((yes-or-no-p "Hyphenate whole buffer? ") (list (point-min) (point-max) max 'interactive))
	   (t (error "Please mark a region")))))
  (let ((hyph-hack/long-word-regex (rx-to-string `(>= ,(or max-length 50) (syntax word)))))
    (save-excursion
      (goto-char start)
      (atomic-change-group
	(insert
	 (hyph-hack/hyphenate-long-string
	  (hyph-hack/devanāgarī-hyphenate-string
	   (delete-and-extract-region start end))))))))

;; (message "argv: %s" argv)

(defun hyph-hack/help ()
  (message "
This script inserts hyphenation marks (BREAK
PERMITTED HERE) in unicode devanāgarī text, to help with
splitting long compounds.

Call it as `hyphenate.sh < ./path/to/your/file >
./path/to/results' or `hyphenate.sh ./path/to/your/file'.  

The second invocation loads the whole file, the first streams it
line by line.  Result should be the same.

It does not touch any other text, so, unless you have special
constructs in devanāgarī (commands of some sort, or xml tags),
the changes should not do much harm™.\n"))

(when noninteractive
  (cond
   ((= 1 (length argv))
    (let (line)
      (condition-case nil ;; ignore stdin errors at the end
	  (while (setq line (read-from-minibuffer ""))
	    (princ (hyph-hack/hyphenate-long-string
		    (hyph-hack/devanāgarī-hyphenate-string line)))
	    (princ "\n"))
	(error nil))))
   ((and (= 2 (length argv)) (not (string= "-h" (cadr argv))))
    (let ((file (expand-file-name (cadr argv))))
      (if (file-readable-p file)
	  (with-temp-buffer
	    (insert-file-contents file)
	    (princ (hyph-hack/hyphenate-long-string
		    (hyph-hack/devanāgarī-hyphenate-string
		     (delete-and-extract-region (point-min) (point-max))))))
	(error "Can't open file %s" file))))
   ((and (cdr argv) (string= "-h" (cadr argv)) (hyph-hack/help)))
   (t (error (hyph-hack/help))))
  (setq argv nil))


(provide 'hyph-hack)
