(defpackage :cl-izhora
  (:use :common-lisp)
  (:export make-izhora
	   izhora-code
	   izhora-pc
	   izhora-a
	   izhora-r1
	   izhora-r2
	   izhora-state
	   izhora-regmode
	   izhora-counter
	   step-program
	   set-command
	   set-data
	   set-data-list
	   display-run
	   print-machine-state
	   save-machine-state
	   ))

(in-package :cl-izhora)
	
