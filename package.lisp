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
	   print-machine
	   save-machine
	   load-machine
	   cutoff-comments
	   parse-word
	   asm-raw-load
	   list-replace
	   asm-compile
	   asm-compile-file
	   asm-to-machine
	   compile-asm-to-machine
	   *standard-macros*
	   *standard-data*
	   ))

(in-package :cl-izhora)
	
