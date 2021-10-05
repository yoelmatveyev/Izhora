(in-package :cl-izhora)

;; Add a command that moves the negative of a cell to another cell that has 0

(defun add-negmove (machine a1 a2)
  (let ((pc (izhora-pc machine)))
    (set-command machine pc (incf pc) #xffff)
    (set-command machine pc (incf pc) #xffff)
    (set-command machine pc (incf pc) a1)
    (set-command machine pc (incf pc) a2)
    (setf (izhora-pc machine) pc)))

;; The same as above, if the accumulator is also 0
	
(defun add-negmove-0 (machine a1 a2)
  (let ((pc (izhora-pc machine)))
    (set-command machine pc (incf pc) a1)
    (set-command machine pc (incf pc) a2)
    (setf (izhora-pc machine) pc)))
    
       
