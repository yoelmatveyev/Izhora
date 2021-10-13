(in-package :cl-izhora)

(defparameter *standard-macros* (make-hash-table))

(defparameter *standard-data*
  '((L =0)(D "word" "$0")
    (L =1)(D "word" "$1")
    (L =16)(D "word" "$16")
    (L =32)(D "word" "$32")
    (L TMP0)(D "word" "$0")
    (L TMP1)(D "word" "$0")
    (L TMP2)(D "word" "$0")
    (L TMP3)(D "word" "$0")
    (L TMP4)(D "word" "$0")
    (L TMP5)(D "word" "$0")
    (L TMP6)(D "word" "$0")
    (L TMP7)(D "word" "$0")
    (L SYS0)(D "word" "$0")
    (L SYS1)(D "word" "$0")
    (L SYS2)(D "word" "$0")
    (L SYS3)(D "word" "$0")))
    
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
	 (list 'C 'SUBLEQ 1 "$=0")
	 (list 'C 'SUBLEQ 1 y)
	 (list 'C 'ZERO "$=0")
	 ))
      
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
