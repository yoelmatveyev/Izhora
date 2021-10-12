(in-package :cl-izhora)

(defparameter *standard-macros* (make-hash-table))

(defparameter *standard-data*
  '((L BIT-SPLIT)(D "word"
		  "$0x00270001" "$0" "$0" "$0" "$0" "$0" "$0" "$0"
		           "$0" "$0" "$0" "$0" "$0" "$0" "$0" "$0"
		           "$0" "$0" "$0" "$0" "$0" "$0" "$0" "$0"
		           "$0" "$0" "$0" "$0" "$0" "$0" "$0" "$0")
    (L =0)(D "word" "$0")
    (L =1)(D "word" "$1")
    (L =16)(D "word" "$16")
    (L TMP0)(D "word" "$0")
    (L TMP1)(D "word" "$0")
    (L TMP2)(D "word" "$0")
    (L TMP3)(D "word" "$0")))
    
(setf (gethash 'ZERO *standard-macros*)
      (lambda (x)
	(list
	 (list 'C 'SUBLEQ 1 x)
	 (list 'C 'SUBLEQ 1 x)))

      (gethash 'MOVM *standard-macros*)
      (lambda (x y)
	(list
	 (list 'C 'ZERO y)
	 (list 'C 'SUBLEQ 1 x)
	 (list 'C 'SUBLEQ 1 y)))

      (gethash 'SUB *standard-macros*)
      (lambda (x y)
	(list
	 (list 'C 'ZERO "$=0")
	 (list 'C 'SUBLEQ 1 x)
	 (list 'C 'SUBLEQ 1 y)))
      
      (gethash 'ADD *standard-macros*)
      (lambda (x y)
	(list
	 (list 'C 'ZERO "$=0")
	 (list 'C 'SUBLEQ 1 x)
	 (list 'C 'SUBLEQ 1 y)))
      
      (gethash 'MOV *standard-macros*)
      (lambda (x y)
	(list
	 (list 'C 'ZERO y)
	 (list 'C 'SUBLEQ 1 x)
	 (list 'C 'SUBLEQ 1 "$=0")
	 (list 'C 'SUBLEQ 1 y)
	 (list 'C 'ZERO "$=0")))

      (gethash 'JMP *standard-macros*)
      (lambda (x)
	(list
	 (list 'C 'SUBLEQ 1 "$=0")
	 (list 'C 'SUBLEQ x "$=0"))))
