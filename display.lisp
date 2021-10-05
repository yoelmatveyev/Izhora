(in-package :cl-izhora)

(defparameter *red* sdl:*red*)
(defparameter *black* sdl:*black*)

(defparameter disp-add #x400)

(defun n-bit (x n)
  (mod (ash x (- n 31)) 2))

(defun get-pixel (machine x y)
  (if (zerop
       (n-bit
	(aref (izhora-code machine)
	      (+ disp-add (- 3 (floor x 32)) (* y 4)))
	(mod x 32)))
      nil t))

(defun display-run (machine &key (run t) (speed 1))
  (let (pixel)
  (sdl:with-init ()
    (sdl:window 1280 640 :title-caption "Simulator of the Izhora cellular automation computer")
    (setf (sdl:frame-rate) 30)
    (sdl:with-events ()
      (:quit-event () t)
      (:key-down-event ()
       (sdl:push-quit-event))
      (:idle ()
	     ;; Draw the display
	     (loop for x from 0 to 127 do
	       (loop for y from 0 to 63 do
	       (setf pixel (get-pixel machine x y))
		   (sdl:draw-box
		    (sdl:rectangle-from-midpoint-*
		     (+ 5 (* x 10)) (+ 5 (* y 10)) 9 9)
                    :color (if pixel *red* *black*))))
	     ;; Redraw the display
	     (sdl:update-display)
    (when run (step-program machine speed)))
    ))))
