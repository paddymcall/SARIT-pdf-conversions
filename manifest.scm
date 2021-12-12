;; Usage: guix shell --check -m manifest.scm
(specifications->manifest
 '("guile@3.0.7"
   "make"
   "texlive-context"))

