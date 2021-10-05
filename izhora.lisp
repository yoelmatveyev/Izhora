(in-package :cl-izhora)

(ql:quickload "lispbuilder-sdl")
(ql:quickload "bordeaux-threads")

;; The main structure that stores an Izhora machine and its state 

(defstruct izhora
  (code (make-array (expt 2 16) :element-type '(unsigned-byte 32))) 
  (pc 0 :type (unsigned-byte 16)) 
  (a (make-array 4 :element-type '(unsigned-byte 32)))
  (r1 (make-array 4 :element-type '(unsigned-byte 32)))
  (r2 (make-array 4 :element-type '(unsigned-byte 32)))
  (state 0 :type (unsigned-byte 16))
  (regmode 0 :type (unsigned-byte 16))
  (time 0 :type (unsigned-byte 32))
  (counter 0))

(defun risc (machine opcode op)
  )

(defun step-program (machine &optional (steps 1))
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (let ((pc 0) (a 0) (code 0) (jmp 0) (op 0))
    (declare (type (unsigned-byte 32) a code))
    (declare (type (unsigned-byte 16) pc jmp op))
    (loop for x from 1 to steps do
      (setf
     pc (izhora-pc machine)
     a  (aref (izhora-a machine) 0)
     code (aref (izhora-code machine) pc)
     jmp (ash code -16)
     op (logand code #xffff))
      (if (>= jmp #xfff0)
	  (progn
	    (risc machine (logand jmp #xf) op)
	    (setf (izhora-pc machine)
		  (logand (1+ pc) #xffff)))
	(progn
	  (setf  (aref (izhora-a machine) 0)
		 (logand (- (aref (izhora-code machine) op) a) #xffffffff)
		 (aref (izhora-code machine) op) (aref (izhora-a machine) 0))
	  (if (or (zerop (aref (izhora-a machine) 0))
		  (> (aref (izhora-a machine) 0) #x7fffffff))
	      (setf (izhora-pc machine)
		    jmp)
	      (setf (izhora-pc machine)
		    (logand (1+ pc) #xffff)))))
    (setf (izhora-counter machine) (1+ (izhora-counter machine))))))
