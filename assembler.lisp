(in-package :cl-izhora)

(defun cutoff-comments (line)
  (string-trim '(#\Space #\Backspace #\Tab)
   (subseq line 0 (search "#" line))))

(defun parse-word (string)
  (let (res)
    (if (numberp string) (setf res string) 
	(progn
	  (setf string (concatenate 'string string "  "))
	  (when (equal (subseq string 0 1) "$")
	    (setf string (subseq string 1 (length string))))
	  (if (equal (string-upcase (subseq string 0 2)) "0X")
	      (setf res (parse-integer
			 (subseq string 2 (length string)) :radix 16 :junk-allowed t))
	      (if (equal (string-upcase (subseq string 0 2)) "0B")
		  (setf res (parse-integer
			     (subseq string 2 (length string)) :radix 2 :junk-allowed t))
		  (setf res (parse-integer string :junk-allowed t))))))
    res))

(defun asm-line-addr (l)
  (if (equal (nth (- (length l) 2) l) :ADDR)
      (car (last l))
      nil))

(defun split-asm-line (line)
  (setf line (substitute #\Space #\, line)
	line (substitute #\Space #\Tab line))
  (loop for i = 0 then (1+ j)
	as j = (position #\Space line :start i)
	collect (subseq line i j)
	while j))
      
(defun read-asm-line (line)
  (setf line (cutoff-comments line))
  (if (find #\: line)
      (list 'l (subseq line 0 (search ":" line)))
      (if (eq (search "." line) 0)
	  (append '(d) (split-asm-line
			(subseq line (1+ (search "." line))
				(length line))))
	  (append '(c) (split-asm-line line)))))

(defun asm-raw-load (file)
  (let (asm-list sexpr)
    (with-open-file
	(stream file
		:direction :input :if-does-not-exist nil)
      (when stream
	(loop for line = (read-line stream nil)
              while line
              do
		 (setf line (cutoff-comments line))
		 (when (> (length line) 0)
		   (setf sexpr (read-asm-line line))
		   (if sexpr (push sexpr asm-list))))))
    (reverse asm-list)))

(defun list-replace (l index new-value)
  (setf l (remove-if (constantly t) l :start index :count 1)
	l (append nil (subseq l 0 index) new-value (subseq l index (length l)))))

(defun asm-fix-subleq (asm-list)
  (loop for x in asm-list do
    (when (and (eq (car x) 'C)
	       (member (string-upcase (cadr x))
		       '("SUBLEQ" "S" "SUBLEQ2" "S2" "SBLQ" "-?") :test #'equal))
      (setf (cadr x) 'SUBLEQ)))
  asm-list)

(defun asm-expand-1-macro (asm-list &key (macros *standard-macros*))
  (loop for x from 0 to (length asm-list) do
    (when (and (eq (car (nth x asm-list)) 'C)
	       (not (equal (cadr (nth x asm-list)) 'SUBLEQ)))
      (setf asm-list (list-replace asm-list x
				   (apply (gethash (intern
						    (string-upcase (cadr (nth x asm-list))))
						   macros)
					  (cddr (nth x asm-list)))))
      (return asm-list))))

(defun asm-expand-macros (asm-list &key (macros *standard-macros*))
  (let (l)
    (loop while (setf l (asm-expand-1-macro asm-list :macros macros))
	  do (setf asm-list l))
    asm-list))

(defun asm-expand-1-dir (asm-list)
  (loop for x from 0 to (length asm-list) do
    (when (eq (car (nth x asm-list)) 'D)
      (when (and
	     (equal (string-upcase (cadr (nth x asm-list))) "WORD")
	     (not (symbolp (cadr (nth x asm-list)))))
	(setf asm-list (list-replace asm-list x
				     (loop for n in (cddr (nth x asm-list))
					   collect (list 'D 'WORD n))))
	(return asm-list))
      (when (and
	     (equal (string-upcase (cadr (nth x asm-list))) "ORG")
	     (not (symbolp (cadr (nth x asm-list)))))
	(setf (cadr (nth x asm-list)) 'ORG)
	(return asm-list)))))

(defun asm-expand-dir (asm-list)
  (let (l)
    (loop while (setf l (asm-expand-1-dir asm-list))
	  do (setf asm-list l))
    asm-list))

(defun asm-assign-addr (asm-list &key (offset 0))
  (let ((cur offset) label-list org caddr-line)
    (loop for x from 0 to (length asm-list) do
      (case (car (nth x asm-list))
	(C
	 (setf (nth x asm-list) (append (nth x asm-list) (list :addr cur)))
	 (incf cur))
	(L
	 (push (cons (string-upcase (cadr (nth x asm-list))) cur) label-list))
	(D
	 (case (cadr (nth x asm-list))
	   (WORD	       
	    (setf (nth x asm-list) (append (nth x asm-list) (list :addr cur)))
	    (incf cur))
	   (ORG
	    (setf caddr-line (caddr (nth x asm-list)))
	    (if (setf org (parse-word caddr-line))
		(if (equal (subseq caddr-line 0 1) "$")
		    (setf cur org)
		    (setf cur (mod (+ cur org) #x10000)))
		(format t "Warning: Indirect addresses in .org not supported~%")))))))
    (append (list 'LBL label-list) asm-list)))

(defun asm-label-addr (lb asm-list)
  (let (res)
  (loop for x in (cadr asm-list) do
    (when (equal (car x) (string-upcase lb))
      (setf res (cdr x))))
    res))

(defun asm-parse-pass1 (asm-list)
  (let (lb-addr word)
    (loop for x in (cddr asm-list) do
      (case (car x)
	(C
	 (loop for y from 0 to 1 do 
	   (if (and
		(arrayp (nth y (cddr x)))
		(equal (subseq (nth y (cddr x)) 0 1) "$"))
	       (if (setf word (parse-word (nth y (cddr x))))
		   (setf (nth y (cddr x)) (mod word #x10000))
		   (if (setf lb-addr
			     (asm-label-addr
			      (subseq (nth y (cddr x))
				      1
				      (length (nth y (cddr x))))
			      asm-list))
		       (setf (nth y (cddr x)) lb-addr)
		       (format t "Warning: Label ~a not found~%"
			       (subseq (nth y (cddr x)) 1 (length (nth y (cddr x)))))))
	       (if (setf word (parse-word (nth y (cddr x))))
		   (setf (nth y (cddr x)) (mod (+ word (asm-line-addr x)) #x10000))
		   (if (setf lb-addr (asm-label-addr (nth y (cddr x)) asm-list))
		       (format t "Warning: Indirect label~%")
		       (format t "Warning: Label ~a not found~%" (nth y (cddr x))))))))
	(D
	 (if (numberp (caddr x))
	     (setf (caddr x) (mod (+ word (asm-line-addr x)) #x10000))
	     (if (equal (cadr x) 'WORD)
		 (if (equal (subseq (caddr x) 0 1) "$")
		     (if (setf word (parse-word (caddr x)))
			 (setf (caddr x) word)
			 (if (setf lb-addr (asm-label-addr
					    (subseq (caddr x) 1 (length (caddr x)))
					    asm-list))
			     (setf (caddr x) lb-addr)
			     (format t "Warning: Label ~a not found~%"
				     (subseq (caddr x) 1 (length (caddr x))))))
		     (if (setf word (parse-word (caddr x)))
			 (setf (caddr x) (mod (+ word (asm-line-addr x)) #x10000))
			 (format t "Warning: Indirect label~%"))))))))
    asm-list))

(defun asm-label-value (lb asm-list)
  (let ((addr (asm-label-addr lb asm-list))res)
    (loop for y in (cddr asm-list) do
	(when (eq (asm-line-addr y) addr)
	  (case (car y)
	    (C
	     (setf res (cadddr y)))
	    (D
	     (if (equal (cadr y) 'WORD)
		 (setf res (mod (caddr y) #x10000)))))))
   (if (numberp res) res nil)))

(defun asm-parse-labels (asm-list)
  (let ((flag1 t) flag2 val)
    (loop while flag1 do
      (setf flag1 nil flag2 nil)
      (loop for x in (cddr asm-list) do
	(case (car x)
	  (C
	   (unless (numberp (caddr x))
		   (if (setf val (asm-label-value (caddr x) asm-list))
		       (setf (caddr x) val
			     flag1 t)
		       (setf flag2 (caddr x))))
	   (unless (numberp (cadddr x))
	     (if (setf val (asm-label-value (cadddr x) asm-list))
		 (setf (cadddr x) val
		       flag1 t)
		 (setf flag2 (cadddr x)))))
	  (D
	   (when (equal (cadr x) 'WORD)
	     (unless (numberp (caddr x))
			      (if (setf val (asm-label-value (caddr x) asm-list))
				  (setf (caddr x) val
					flag1 t)
				  (setf flag2 (caddr x)))))))))
      (if flag2
	  (format t "Compilation failed: Unresolvable label ~a~%" flag2)
	  asm-list)))

(defun asm-compile (asm-list &key (offset nil)(macros nil)(var nil)(var-addr 0))
    (loop for x in asm-list do
      (if (and (equal (car x) 'D) (equal (string-upcase (cadr x)) "STDMACROS")(not macros))
	  (setf macros *standard-macros*))
      (if (and (equal (car x) 'D) (equal (string-upcase (cadr x)) "STDVARS")(not var))
	  (setf var *standard-data*)))	
    (setf asm-list
	  (append
	   (if var
	       (append (list (list 'D "org"
			   (concatenate 'string "$" (write-to-string var-addr))))
	       var))
	   (if offset (list (list 'D "org" (write-to-string offset))))
	   asm-list))
    (asm-parse-labels
     (asm-parse-pass1
      (asm-assign-addr
       (asm-expand-dir
	(asm-expand-macros
	 (asm-fix-subleq asm-list)	
	 :macros macros))
       :offset offset))))

(defun asm-compile-file (file &key
				(offset 0)
				(macros nil)
				(var nil)
				(var-addr 0))
  (asm-compile (asm-raw-load file) :offset offset :macros macros :var var :var-addr var-addr))

(defun asm-to-machine (asm-list machine)
  (let (setpc)
  (loop for x in (cddr asm-list) do
    (when (equal (car x) 'C)
      (set-command machine (asm-line-addr x) (caddr x) (cadddr x)))
    (when (and (equal (car x) 'D) (equal (cadr x) 'WORD))
      (set-data machine (asm-line-addr x) (caddr x))))
    (setf setpc (asm-label-addr "_setpc" asm-list))
    (if setpc (setf (izhora-pc machine) setpc))))

(defun asm-compile-file-to-machine (file machine &key
					      (offset 0)
					      (macros nil)
					      (var nil)
					      (var-addr 0))
  (asm-to-machine
   (asm-compile-file file :offset offset :macros macros :var var :var-addr var-addr)
		     machine))
