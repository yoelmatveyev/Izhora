(in-package :cl-izhora)

(defun cutoff-comments (line)
  (string-trim '(#\Space #\Backspace #\Tab)
   (subseq line 0 (search "#" line))))

(defun immedp (string)
  (if (numberp string) nil
      (if (equal (subseq string 0 1) "$") t nil)))

(defun cut-$ (string)
      (if (or (numberp string) (equal string ""))
      string
      (if (equal (subseq string 0 1) "$")
      (subseq string 1 (length string))
      string)))

(defun add-$ (n)
  (if (immedp n) n
      (concatenate 'string "$"
		   (if (numberp n)
		       (write-to-string n)
		       n))))

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
	  (remove "" (append '(c) (split-asm-line line)) :test #'equal))))

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
	     (equal (string-upcase (cadr (nth x asm-list))) "GLOBAL")
	     (not (symbolp (cadr (nth x asm-list)))))
	(setf (cadr (nth x asm-list)) 'GLOBAL)
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
	    (when (immedp caddr-line)
	      (format t "Warning: ignoring $ in .org ~a~%" org)
	      (setf org (cut-$ org)))
	    (if (setf org (parse-word caddr-line))
		(setf cur org)
		(if (setf org (asm-label-addr caddr-line label-list :label-list t))
		    (progn
		      (setf cur org)
		      (format t "Warning: .org backwards to ~a~%" caddr-line))
		    (progn
		      (setf cur (asm-label-value caddr-line asm-list label-list))
		      (format t "Unknown label in .org~%")))))))))
    (append (list 'LBL label-list) asm-list)))

(defun asm-label-addr (lb asm-list &key (label-list nil))
  (let (res	
	(l (if label-list asm-list (cadr asm-list))))
    (setf lb (cut-$ lb))
    (if (numberp lb) (setf res nil)
	(loop for x in l do
	  (when (equal (car x) (string-upcase lb))
	    (setf res (cdr x)))))
	res))

(defun asm-parse-labels (asm-list)
  (let ((flag1 t) flag2 val)
    (loop while flag1 do
      (setf flag1 nil flag2 nil)
      (loop for x in (cddr asm-list) do
	(case (car x)
	  (C 
	   (if (setf val (asm-label-addr (cut-$ (caddr x)) asm-list))
	       (progn (setf (caddr x) (add-$ val) flag1 t)
		      (unless (immedp (caddr x))
			  (format t "Warning: ignoring indirect address in SUBLEQ~%"))) 
	       (unless (parse-word (caddr x))
		 (setf flag2 (caddr x))))
	   (if (setf val (asm-label-addr (cut-$ (cadddr x)) asm-list))
	       (progn (setf (cadddr x) (add-$ val) flag1 t)
		      (unless (immedp (cadddr x))
			(format t "Warning: ignoring indirect operand in SUBLEQ~%")))
	        (unless (parse-word (cadddr x))
		  (setf flag2 (cadddr x)))))
	  (D
	   (case (cadr x)
	     (WORD
	      (when (immedp (caddr x))
		(format t "Warning: ignoring $ in data directive~%"))
	      (if (setf val (asm-label-addr (cut-$ (caddr x)) asm-list))
		  (setf (caddr x) val
			  flag1 t)
		  (unless (parse-word (caddr x))(setf flag2 (caddr x))))))))))
    (loop for x in (cdr asm-list) do
      (if (and (equal (car x) 'D) (equal (cadr x) 'GLOBAL))
   	  (if (setf val (asm-label-addr (caddr x) asm-list))
	      (setf (caddr x) val)
	      (setf flag2 (caddr x))))) 	  
      (if flag2
	  (format t "Error: Unresolvable label ~a~%" flag2)
	  asm-list)))

(defun asm-compile (asm-list &key (offset nil)(macros nil)(var nil)(var-addr 0))
    (loop for x in asm-list do
      (if (and (equal (car x) 'D) (equal (string-upcase (cadr x)) "STDMACROS")(not macros))
	  (setf macros *standard-macros*))
      (if (and (equal (car x) 'D) (equal (string-upcase (cadr x)) "STDVARS")(not var))
	  (setf var *standard-data*)))	
    (setf asm-list
	  (append
	   (list (list 'D "org" (write-to-string var-addr)))
	   (if var var)
	   (if offset (list (list 'D "org" (write-to-string offset))))
	   asm-list))
    (asm-parse-labels
     (asm-assign-addr
      (asm-expand-dir
       (asm-expand-macros
	(asm-fix-subleq asm-list)	
	:macros macros))
      :offset offset)))

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
      (unless (immedp (caddr x))
	(setf (caddr x) (mod (+ (parse-word (caddr x)) (asm-line-addr x)) #x10000)))
      (unless (immedp (cadddr x))
	(setf (cadddr x) (mod (+ (parse-word (cadddr x)) (asm-line-addr x)) #x10000)))
      (set-command machine (asm-line-addr x) (parse-word (caddr x)) (parse-word (cadddr x))))
    (when (and (equal (car x) 'D) (equal (cadr x) 'WORD))
      (set-data machine (asm-line-addr x) (parse-word (caddr x))))
    (when (and (equal (car x) 'D) (equal (cadr x) 'GLOBAL))
      (setf setpc (caddr x))))
    (if setpc (setf (izhora-pc machine) setpc))))

(defun asm-compile-file-to-machine (file machine &key
					      (offset 0)
					      (macros nil)
					      (var nil)
					      (var-addr 0))
  (asm-to-machine
   (asm-compile-file file :offset offset :macros macros :var var :var-addr var-addr)
		     machine))
