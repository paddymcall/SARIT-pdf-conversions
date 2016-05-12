#! /bin/sh
":"; exec emacs --no-site-file --script "$0" -- "$@" # -*-emacs-lisp-*-
(defun hacks/devanāgarī-hyphenate-string (string &optional verify)
  "Insert ?130 (break permitted here) into STRING.

It effectively splits up unicode devanāgarī strings.  If VERIFY
is not nil, compare the results with the original string (if,
after removal of all ?130, it's the same, return it; otherwise,
raise an error).  Should ignore stuff other than devanāgarī."
  (let ((src (string-to-list string))
	(vowels ;; (-flatten (first indian-dev-base-table))
	 '(2309 2310 2366 2311 2367 2312 2368 2313 2369 2314 2370 2315 2371 2316 2402 2317 2373 2318 2374 2319 2375 2320 2376 2321 2377 2322 2378 2323 2379 2324 2380 2400 2372 2401 2403))
	(consonants ;; (butlast (butlast (-flatten (second indian-dev-base-table))))
	 '(2325 2326 2327 2328 2329 2330 2331 2332 2333 2334 2335 2336 2337 2338 2339 2340 2341 2342 2343 2344 2345 2346 2347 2348 2349 2350 2351 2352 2353 2354 2355 2356 2357 2358 2359 2360 2361 2392 2393 2394 2395 2396 2397 2398 2399))
	(virāma 2381)
	(break-permitted 130)
	item results)
    (while src
      (setq item (pop src))
      (cond
       ((and
	 (member item consonants)
	 (member (car src) consonants))
	(push item results)
	(push break-permitted results))
       ((and
	 (member item vowels)
	 (member (car src) consonants))
	(push item results)
	(push break-permitted results))
       (t (push item results))))
    (if verify
      (if (string= (concat (delq break-permitted (reverse results)))
		   string)
	  (concat (reverse results))
	(error "Lost some stuff here: %s vs %s" string
	       (concat (delq break-permitted (reverse results)))))
      (concat (reverse results)))))

;; (message "argv: %s" argv)

(defun hyphenate-help ()
  (message "
This script inserts hyphenation marks (BREAK
PERMITTED HERE) in unicode devanāgarī text, to help with
splitting long compounds.

Call it as `hyphenate.sh < ./path/to/your/file > ./path/to/results'

It does not touch any other text, so, unless you have special
constructs in devanāgarī (commands of some sort, or xml tags),
the changes should not do much harm™.\n"))

(cond
 ((= 1 (length argv))
  (let (line)
    (while (setq line (read-from-minibuffer ""))
      (princ (hacks/devanāgarī-hyphenate-string line))
      (princ "\n"))))
 ((and (cdr argv) (string= "-h" (cadr argv)) (hyphenate-help)))
 (t (error (hyphenate-help))))

(setq argv nil)
