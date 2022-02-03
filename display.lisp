(in-package :cl-izhora)

(defparameter *red* sdl:*red*)
(defparameter *yellow* sdl:*yellow*) 
(defparameter *black* sdl:*black*)

(defparameter disp-add #x400)

(defun n-bit (x n)
  (mod (ash x (- n 31)) 2))

(defparameter shift 0)
(defparameter ctrl 0)

(defparameter display-speed 8)

(defparameter display-color *red*)

(defparameter display-large nil)

(defparameter paused nil)

(defparameter izhora-keyboard-table
  '(
   (:SDL-KEY-F1 25) (:SDL-KEY-F2 8) (:SDL-KEY-F3 55) (:SDL-KEY-F4 38)
   (:SDL-KEY-F5 21) (:SDL-KEY-F6 4) (:SDL-KEY-F11 17) (:SDL-KEY-F12 12)
   (:SDL-KEY-BACKSPACE 17) (:SDL-KEY-INSERT 51) (:SDL-KEY-DELETE 34)
   (:SDL-KEY-BACKQUOTE 59) (:SDL-KEY-BACKSLASH 42)

   (:SDL-KEY-1 41) (:SDL-KEY-2 24) (:SDL-KEY-3 7) (:SDL-KEY-4 54)
   (:SDL-KEY-5 37) (:SDL-KEY-6 20) (:SDL-KEY-7 3) (:SDL-KEY-8 50)
   (:SDL-KEY-9 33) (:SDL-KEY-0 16) (:SDL-KEY-MINUS 63)
   (:SDL-KEY-EQUALS 46) (:SDL-KEY-RETURN 29)

   (:SDL-KEY-Q 6) (:SDL-KEY-W 53) (:SDL-KEY-E 36) (:SDL-KEY-R 19)
   (:SDL-KEY-T 2) (:SDL-KEY-Y 49) (:SDL-KEY-U 32) (:SDL-KEY-I 15)
   (:SDL-KEY-O 62) (:SDL-KEY-P 45) (:SDL-KEY-LEFTBRACKET 28)
   (:SDL-KEY-RIGHTBRACKET 11) (:SDL-KEY-UP 58)
   
   (:SDL-KEY-A 35) (:SDL-KEY-S 18) (:SDL-KEY-D 1) (:SDL-KEY-F 48)
   (:SDL-KEY-G 31) (:SDL-KEY-H 14) (:SDL-KEY-J 61) (:SDL-KEY-K 44)
   (:SDL-KEY-L 27) (:SDL-KEY-SEMICOLON 10) (:SDL-KEY-QUOTE 57)
   (:SDL-KEY-LEFT 40) (:SDL-KEY-RIGHT 23)
   
   (:SDL-KEY-Z 47) (:SDL-KEY-X 30) (:SDL-KEY-C 13) (:SDL-KEY-V 60)
   (:SDL-KEY-B 43) (:SDL-KEY-N 26) (:SDL-KEY-M 6) (:SDL-KEY-COMMA 56)
   (:SDL-KEY-PERIOD 39) (:SDL-KEY-SLASH 22) (:SDL-KEY-SPACE 5)
   (:SDL-KEY-DOWN 52)))

;;; Get a pixel from RAM for the legacy machines with a 128x64 display

(defun get-pixel-legacy (machine x y)
  (if (zerop
       (n-bit
	(aref (izhora-code machine)
	      (+ disp-add (- 3 (floor x 32)) (* y 4)))
	(mod x 32)))
      nil t))

;;; Get a pixel from RAM for machines with a 256x128 display

(defun get-pixel (machine x y)
  (if (zerop
       (n-bit
	(aref (izhora-code machine)
	      (+ disp-add (floor (- 255 x) 32) (* (- 127 y) 8)))
	(mod x 32)))
      nil t))

(defun process-key (machine key)
  (let (code)
    (if (or (eq key :SDL-KEY-LSHIFT)(eq key :SDL-KEY-RSHIFT))
	(setf shift 1)
	(if (or (eq key :SDL-KEY-LCTRL)(eq key :SDL-KEY-RCTRL))
	    (setf ctrl 1)
	    (if (= (izhora-sc machine) 0)
		(setf code (cadr (assoc key izhora-keyboard-table))
		      code (+ (* shift 64) (* ctrl 128) (if code code 0))
		      (izhora-sc machine) code))))
    (when (= 0 (aref (izhora-code machine) #xffff))
	(setf (aref (izhora-code machine) #xffff) (izhora-sc machine)
	      (izhora-sc machine) 0)
	(if (and (numberp code) (plusp code))
	    (setf shift 0
		  ctrl 0)))))

(defun caption (machine speed)
  (let ((model (izhora-model machine))
	(ct (izhora-ct machine)))
    (setf model
	  (case model
	  (0 "1") (1 "1A") (2 "1B")))	
    (format nil
	    "Izhora ~a Simulator   Speed: 8^~d   Count: ~a ~a"
	    model (floor (log speed 8)) ct
	    (if paused "(Paused)" ""))))
	  
;;; Run simulator

(defun display-run (machine &key (run t) (speed display-speed))
  (let (pixel)
    (sdl:with-init ()
      (if display-large
        (sdl:window 1920 960 :title-caption (caption machine speed))
        (sdl:window 1280 640 :title-caption (caption machine speed)))
      (setf (sdl:frame-rate) 30)
      (sdl:with-events ()
	(:quit-event () t)
	(:key-down-event (:key key)
			 (when (eq key :SDL-KEY-F7)
			   (if display-large
			       (setf display-large nil)
			       (setf display-large t)))
			 (when (eq key :SDL-KEY-F8)
			   (if (eq display-color *red*)
			       (setf display-color *yellow*)
			       (setf display-color *red*)))
			 (when (eq key :SDL-KEY-F9)
			   (setf speed (+ (floor (/ speed 8)) 8)))
			 (when (eq key :SDL-KEY-F10)
			   (if (plusp shift)
			       (if paused
				   (setf paused nil)
				   (setf paused t))
			       (setf speed (floor (* speed 8)))))
			 (process-key machine key)
			 (if (eq key :SDL-KEY-ESCAPE)
			     (sdl:push-quit-event)))
	(:idle ()
	       (if display-large
		   ;; Larger screen
		   (progn
		     (sdl:window 1920 960 :title-caption (caption machine speed))
		     ;; Draw the display
		     (if (< (izhora-model machine) 2)
			 ;; For 128x64 legacy machines
			 (loop for x from 0 to 127 do
			   (loop for y from 0 to 63 do
			     (setf pixel (get-pixel-legacy machine x y))
			     (sdl:draw-box
			      (sdl:rectangle-from-midpoint-*
			       (+ 5 (* x 15)) (+ 5 (* y 15)) 13 13)
			      :color (if pixel display-color *black*))))	
			 ;; For 256x128 machines
			 (loop for x from 0 to 255 do
			   (loop for y from 0 to 127 do
			     (setf pixel (get-pixel machine x y))
			     (sdl:draw-box
			      (sdl:rectangle-from-midpoint-*
			       (+ 5 (* x 7.5)) (+ 5 (* y 7.5)) 6 6)
			      :color (if pixel display-color *black*))))))
		   ;; Smaller screen
		   (progn
		     (sdl:window 1280 640 :title-caption (caption machine speed))
		     ;; Draw the display
		     (if (< (izhora-model machine) 2)
			 ;; For 128x64 legacy machines
			 (loop for x from 0 to 127 do
			   (loop for y from 0 to 63 do
			     (setf pixel (get-pixel-legacy machine x y))
			     (sdl:draw-box
			      (sdl:rectangle-from-midpoint-*
			       (+ 5 (* x 10)) (+ 5 (* y 10)) 9 9)
			      :color (if pixel display-color *black*))))	
			 ;; For 256x128 machines
			 (loop for x from 0 to 255 do
			   (loop for y from 0 to 127 do
			     (setf pixel (get-pixel machine x y))
			   (sdl:draw-box
			    (sdl:rectangle-from-midpoint-*
			     (+ 5 (* x 5)) (+ 5 (* y 5)) 4 4)
			    :color (if pixel display-color *black*)))))))
		   ;; Redraw the display
		   (sdl:update-display)
		   (when run (if paused nil (step-program machine speed))))))))
