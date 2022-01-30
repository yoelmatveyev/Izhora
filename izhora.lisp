(in-package :cl-izhora)

(ql:quickload "lispbuilder-sdl")
(ql:quickload "bordeaux-threads") ; Bordeaux threads are not used yet

;;; The main structure: state of an Izhora machine
;;; Temporary registers of the actual cellular automation not stored
;;; Additional features of the future machines already defined 

(defstruct izhora
  ;;  Default machine model is 2 for Izhora 1b (0 for Izhora 1, 1 for 1a)
  (model 2 :type fixnum)
  (code (make-array (expt 2 16) :element-type 'fixnum)) ; RAM
  (pc 0 :type fixnum) ; PC
  (i0 0 :type fixnum) ; Future interrupt vector 0
  (i1 0 :type fixnum) ; Future interrupt vector 1
  (l 0 :type fixnum) ; Future interrupt level
  ;; Accumulator and future extra registers
  (a 0 :type fixnum)
  (b 0 :type fixnum)
  (c 0 :type fixnum)
  (rp 0 :type fixnum) ; Future return stack pointer
  (sp 0 :type fixnum) ; Future data stack pointer
  (sc 0 :type fixnum) ; Scancode of the last pressed key
  ;; External storage for future models
  (extmem
   (make-array (expt 2 16) :element-type 'fixnum :adjustable t))
  (ct 0)) ; Counter

(defun risc (machine opcode op)
  )

(defun step-program (machine &optional (steps 1))
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (let ((pc 0) (a 0) (code 0) (jmp 0) (op 0)
	(model (izhora-model machine)))
    (declare (type fixnum a code pc jmp op model))
    (if (> model 2)
	;; For future RISC models
	(loop for x from 1 to steps do
	  (setf
	   pc (izhora-pc machine)
	   a  (izhora-a machine)
	   code (aref (izhora-code machine) pc)
	   jmp (ash code -16)
	   op (logand code #xffff))
	  (if (>= jmp #xfff0)
	  ;; RISC features not implemented yet
	      (risc machine (logand jmp #xf) op)
	      (progn
		(setf (izhora-a machine)
		      (logand (- (aref (izhora-code machine) op) a) #xffffffff)
		      (aref (izhora-code machine) op) (izhora-a machine))
		(if (or (zerop (izhora-a machine))
			(> (izhora-a machine) #x7fffffff))
		    (setf (izhora-pc machine)
			  jmp)
		    (setf (izhora-pc machine)
			  (logand (1+ pc) #xffff)))))
	  (setf (izhora-ct machine) (1+ (izhora-ct machine))))
	;; For basic SUBLEQ models
	(loop for x from 1 to steps do
	  (setf
	   pc (izhora-pc machine)
	   a  (izhora-a machine)
	   code (aref (izhora-code machine) pc)
	   jmp (ash code -16)
	   op (logand code #xffff))
	  (setf (izhora-a machine)
		(logand (- (aref (izhora-code machine) op) a) #xffffffff)
		(aref (izhora-code machine) op) (izhora-a machine))
	  (if (or (zerop (izhora-a machine))
		  (> (izhora-a machine) #x7fffffff))
	      (setf (izhora-pc machine)
		    jmp)
	      (setf (izhora-pc machine)
		    (logand (1+ pc) #xffff)))
	  (setf (izhora-ct machine) (1+ (izhora-ct machine)))))))
