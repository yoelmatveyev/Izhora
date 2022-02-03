(in-package :cl-izhora)

(defparameter *standard-macros* (make-hash-table))

(defparameter *standard-data*
  '((L =0)(D "word" 0)
    (L =1)(D "word" 1)
    (L =16)(D "word" 16)
    (L =32)(D "word" 32)
    (L =0x10000)(D "word" #x10000)
    (L =0x20000)(D "word" #x20000)
    (L maxneg)(D "word" #x80000000)
    (L TMP0)(D "word" 0)
    (L TMP1)(D "word" 0)
    (L TMP2)(D "word" 0)
    (L TMP3)(D "word" 0)
    (L TMP4)(D "word" 0)
    (L TMP5)(D "word" 0)
    (L TMP6)(D "word" 0)
    (L TMP7)(D "word" 0)
    (L SYS1)(D "word" 0)))
    
(setf (gethash 'ZERO *standard-macros*)
      (lambda (x)
	(list
	 (list 'C 'SUBLEQ 1 x)
	 (list 'C 'SUBLEQ 1 x)))

      (gethash 'MOVN *standard-macros*)
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
	 (list 'C 'SUBLEQ x "$=0")))
      (gethash 'CALL1 *standard-macros*)
      (lambda (x)
	(list
	 (list 'C 'SUBLEQ 1 "$=0")
	 (list 'C 'SUBLEQ 1 -1)
	 (list 'C 'SUBLEQ x "$=0"))))
