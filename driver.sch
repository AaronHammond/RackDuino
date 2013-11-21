;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  RackDuino                                                              ;
;  A library for use of the Arduino platform in the Racket language.      ;
;  For a more complete description of the library, read the accompanying  ;
;  program description.                                                   ;
;                                                                         ;
;  Programmed by Aaron 'Elephants' Hammond                                ;  
;                                                                         ;
;  note: check expects have been commented out and thus serve more as     ;
;        examples to follow. accessing things that aren't there tends to  ;
;        break things.                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#lang racket

;if prolix is true, then use lots of (displayln)
;to help with debugging. for the end user, this would be false
(define PROLIX true)

;this is the name of the serial port on which the arduino is connected
;this will be available to the end user to edit, based on his needs
(define PORT "com3")

;this is the baud rate of the serial port. different arduino models have
;different baud rates. the uno (platform used for library development)
;runs on 9600 baud
(define BAUD 9600)

;;;;;;;;;;;;;;;
;  Utilities  ;
;;;;;;;;;;;;;;;
;these functions are used to faciliate lib operation

;com-write: string -> void
;given a string to write to the out port
;write to the message to the com port
; (com-write "Hello!")
; "should write 'Hello!' to the out port"
; (com-write "world")
; "should write 'world' to the out port"
; (com-write "I saw the best minds of my generation")
; "should write the first line of that eternal poem to the out port"

(define (com-write message)
  (displayln (if PROLIX (string-append "Writing " message) ""))
  (display message OUT)
  (flush-output OUT)
)

;com-read: void -> string
;return a string of all characters up to an end line character
;or an empty string if the port is empty
; (com-read)
; "should return a string if characters are available, '' if no chars are available"
; (com-read)
; "should return a string if characters are available, '' if no chars are available"
; (com-read)
; "should return a string if characters are available, '' if no chars are available"

 
(define (com-read)
  (displayln (if PROLIX "Reading..." ""))
  (read-line IN 'any)
)

;close-all-ports: void -> void
;given nothing
;closes all ports on the current custodian
;this is mostly used to close the COM ports after they have been opened at
;the beginning of the program
;the COM ports need to be closed. otherwise, bad things (inaccessibility) happens
; (close-all-ports)
; "should close any open TCP, UDP, or COM ports (good thing)"

(define (close-all-ports)
  (displayln (if PROLIX "Closing all ports" ""))
  (custodian-shutdown-all (current-custodian))
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Structures                                                               ;
;   each structure represents a type of physical component on the arduino   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
;  LEDs  ;
;;;;;;;;;;
; a LED is a structure
; (make-led number number)
; port refers to the digital port on the arduino that the LED is plugged into
; state is either 1 or 0 and indicates accordingly whether the LED is on or off
(define-struct led (port state) #:transparent)
(make-led 2 0)
(make-led 3 0)
(make-led 4 1)
; note that, because there's no instantiation associated with creating an LED
; the "real" state will be off once created. if we create an LED with a state of 1
; to begin with, all operations will therefore be reversed
; ;template
; (define (led-func a-led)
;         (... (led-port a-led)...
;              (led-state a-led)...))


;;;;;;;;;;;;;;;;;;;;;;
;  Digital Buttons   ;
;;;;;;;;;;;;;;;;;;;;;;
; a digital button is a structure
; (make-button number boolean)
; port refers to the digital port on the arduino that the button is plugged into
; reversed indicates whether the button wiring is flipped. that is,
; pressing down returns a 0 rather than a 1. functions will then flip accordingly
(define-struct button (port reversed) #:transparent)
(make-button 2 true)
(make-button 4 false)
(make-button 6 false)
; ;template
; (define (button-func a-button)
;   (... (button-port a-button)...
;        (button-reversed a-button)...))


;;;;;;;;;;;;;;;
;  DC Motors  ;
;;;;;;;;;;;;;;;
;a DC motor is a structure
;(make-motor number number)
;port refers to the PWM port on the arduino that the motor is plugged into
;speed (-1.0 - 1.0) refers to the amount of power going to the motor (-5.0v - 5.0v)
(define-struct motor (port speed) #:transparent)
(make-motor 2 0.0)
(make-motor 4 -1.0)
(make-motor 5 0.5)
; ;template
; (define (motor-func a-motor)
;   (... (motor-port a-motor)...
;        (motor-speed a-motor)...))


;;;;;;;;;;;;;;;;;;;;;;;;
;  List of Components  ;
;;;;;;;;;;;;;;;;;;;;;;;;
;a list-of-components is either
;empty, or
;(cons some-component list-of-components)
; note that a component is just some structure that you'd find on the arduino
; for example, a dc motor or a digital button is a component
(cons (make-motor 2 0.0) empty)
(cons (make-motor 3 1.0) (cons (make-button 4 false) empty))
(cons (make-motor 3 1.0) (cons (make-button 4 false) (cons (make-led 3 0.0) empty)))
; ;template
; (define (loc-func list-of-comps)
;   ... (cond [(empty? list-of-comps)...]
;             [else ... (loc-func (rest list-of-comps))]) ...)



;;;;;;;;;;;;;
;  Arduino  ;
;;;;;;;;;;;;;
;an arduino is a structure
;(make-arduino list-of-components string number)
;list-of-components refers to all components (leds, buttons, motors, etc.) on the arduino
;the com string refers to the name of the com port for the microprocessor
;baud refers to the baud rate of the above com port
;this struct effectively contains the "meat and potatoes" of the lib
(define-struct arduino (comps com baud) #:transparent)
(make-arduino (list (make-motor 3 0.0)
                    (make-led 2 0))
              "com3"
              9600)
(make-arduino (list (make-motor 3 0.0)
                    (make-led 2 0)
                    (make-button 5 true))
              "com4"
              4800)
(make-arduino (list (make-motor 3 0.0)
                    (make-led 2 0)
                    (make-button 5 true)
                    (make-button 7 false))
              "com6"
              3200)
; ;template
; (define (arduino an-arduino)
;   (... (arduino-comps an-arduino)...
;        (arduino-com an-arduino)...
;        (arduino-baud an-arduino)...))



;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
;;;  Functions  ;;;
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;

;all commands are sent to the arduino following the same format
;"portnum#command#val\r"
;where
;portnum: some number between 0 and 13
;command: a number 0 - 4 where
; 0 - write (digital)
; 1 - read (digital)
; 2 - write (analog-pwm)
; 3 - read (analog)
;val: either 0 or 1 if digital or a number between 0 and 255
; if analog



;;;;;;;;;;
;  LEDs  ;
;;;;;;;;;;

;led-set: led number -> a-led
;given an led and a number indicating the new state (1 = on, 0 = off)
;set the led on the arduino and return a newly updated led
; (check-expect (led-set (make-led 3 0) 1)
;               (make-led 3 1))
; (check-expect (led-set (make-led 5 0) 0)
;               (make-led 5 0))
; (check-expect (led-set (make-led 2 1) 0)
;               (make-led 2 0))


(define (led-set a-led state)
  (if PROLIX (displayln (string-append "Setting LED " (number->string (led-port a-led)) " to " (number->string state))) "")
  (com-write (string-append (number->string (led-port a-led)) "#" "0" "#" (number->string state)))
  (make-led (led-port a-led) state)
  )
;led-get: led -> boolean
;given an led,
;return a boolean indicating whether the led's state is 1
;(makes for more readable code)
; (check-expect (led-get (make-led 3 0))
;               false)
; (check-expect (led-get (make-led 4 1))
;               true)
; (check-expect (led-get (make-led 5 0))
;               false)


(define (led-get a-led)
  (= (led-state a-led) 1)
)

;led-time-on: led number -> led
;given an led and a number indiciating time in seconds
;return the newly updated LED and
;turn on the led for the given time, and then turn it off
; (check-expect (led-time-on (make-led 3 0) 2)
;               (make-led 3 0))
; (check-expect (led-time-on (make-led 4 1) 3)
;               (make-led 4 0))
; (check-expect (led-time-on (make-led 5 0) 6)
;               (make-led 5 0))


(define (led-time-on a-led t)
  (led-set a-led 1)
  (if PROLIX (displayln (string-append "Waiting for " (number->string t) " seconds")) "")
  (sleep t)
  (led-set a-led 0))

;led-time-off: led number -> led
;given an led and a number indiciating time in seconds
;return the newly updated LED and
;turn off the led for the given time, and then turn it on 
; (check-expect (led-time-off (make-led 3 0) 2)
;               (make-led 3 1))
; (check-expect (led-time-off (make-led 4 1) 3)
;               (make-led 4 1))
; (check-expect (led-time-off (make-led 5 0) 6)
;               (make-led 5 1))


(define (led-time-off a-led t)
  (led-set a-led 0)
  (if PROLIX (displayln (string-append "Waiting for  " (number->string t) " seconds")) "")
  (sleep t)
  (led-set a-led 1))

;led-strobe: led number number -> led
;given an led, a number indicating desired frequency, and 
;a number indicating time in seconds
;return the newly updated LED and
;strobe the led at the desired frequency for the time indicated
;(note: the frequency is in hertz)
; (check-expect (led-strobe (make-led 3 0) 3 2)
;               (make-led 3 0))
; (check-expect (led-strobe (make-led 4 1) 4 1)
;               (make-led 4 1))
; (check-expect (led-strobe (make-led 5 0) (/ 1 3) 2 )
;               (make-led 5 0))

(define (led-strobe a-led freq t)
  ;sets the opposite state of current
  (define temp-led (led-set a-led (if (= (led-state a-led) 1) 0 1)))
  ;sleeps for some time dependent on freq
  (sleep (/ 1 freq))
  ;recurse with the time used subtracted
  (if (not (= (- t (/ 1 freq)) 0))
      (led-strobe temp-led freq (- t (/ 1 freq)))
      a-led))

;;;;;;;;;;;;;;;;;;;;;
;  Digital Buttons  ;
;;;;;;;;;;;;;;;;;;;;;

;button-get: button -> boolean
;given a button,
;return whether the button is currently pressed
;considering whether it is reversed
; (button-get (make-button 3 false)) "returns true when the button on port 3 is pressed"
; (button-get (make-button 4 true)) "returns true when the button on port 4 is pressed"
; (button-get (make-button 5 false)) "returns true when the button on port 5 is pressed"


(define (button-get a-button)
  (com-write (string-append (button-port a-button) "#" "1" "#" "0"))
  (define read (com-read))
  (if (not (button-reversed a-button))
      (= read 1)
      (= read 0))
  )

;button-wait-until-press: button number -> boolean
;given a button and a number indicating time in seconds
;return a boolean indicating whether the button has been pressed (true)
;or indicating that the timeout has expired (false)
;(note: this is generally implemented as a separate thread)
; (button-wait-until-press (make-button 3 false) 5) 
; "returns true if the button on port 3 is pressed within 5 seconds or false otherwise"
; (button-wait-until-press (make-button 4 false) 10) 
; "returns true if the button on port 4 is pressed within 10 seconds or false otherwise" 
; (button-wait-until-press (make-button 5 true) 0.5) 
; "returns true if the button on port 5 is pressed within 0.5 seconds or false otherwise" 


(define (button-wait-until-press a-button timeout)
  (sleep .01)
  (cond [(<= timeout 0) false]
        [(button-get a-button) true]
        [else (button-wait-until-press a-button (- timeout 0.01))])
  )

;;;;;;;;;;;;;;;
;  DC Motors  ;
;;;;;;;;;;;;;;;

;motor-set-speed: motor number -> motor
;given a motor and a number indicating speed (0.0 - 1.0)
;set the motor speed and return the newly updated motor
; (check-expect (motor-set-speed (make-motor 2 0) 1.0)
;               (make-motor 2 1.0))
; (check-expect (motor-set-speed (make-motor 3 -1.0) 1.0)
;               (make-motor 3 1.0))
; (check-expect (motor-set-speed (make-motor 4 0) 0.5)
;               (make-motor 4 0.5))


(define (motor-set-speed a-motor speed)
  (com-write (motor-port a-motor) "#" "2" "#" (* speed 255))
  (make-motor (motor-port a-motor) speed))

;motor-get-speed: motor -> number
;given a motor,
;return its current speed
;(makes for more readable code)
; (check-expect (motor-get-speed (make-motor 3 0.5))
;               0.5)
; (check-expect (motor-get-speed (make-motor 4 0.0))
;               0.0)
; (check-expect (motor-get-speed (make-motor 5 1.0))
;               1.0)

(define (motor-get-speed a-motor)
  (motor-speed a-motor)
  )

;motor-run-at-speed: motor number number -> motor
;given a motor, a number indicating speed, and a number indicating time in seconds
;return the newly updated motor
;run the motor at the given speed for the given time, and then turn it off
; (check-expect (motor-run-at-speed (make-motor 2 0) 1.0 3)
;               (make-motor 2 0.0))
; (check-expect (motor-run-at-speed (make-motor 3 -1.0) 0.5 7)
;               (make-motor 3 0.0))
; (check-expect (motor-run-at-speed (make-motor 4 0) -0.5 0.5)
;               (make-motor 4 0.0))

(define (motor-run-at-speed a-motor speed time)
  (motor-set-speed a-motor speed)
  (sleep time)
  (motor-set-speed a-motor 0.0)
  )


;;;;;;;;;;;;;
;  Arduino  ;
;;;;;;;;;;;;;
;note: please connect your arduino before trying these functions :)

;arduino-connect: arduino -> boolean
;given an arduino
;try to connect over com and returns the in and out ports of the com channel
;works by checking the success (or failure) of the system call setting the
;particulars of the arduino device (baud, port, etc.)
; (arduino-connect (make-arduino (list (make-motor 3 0.0)
;                                      (make-led 2 0))
;                                "com3"
;                                9600))
; "should return true if an arduino is connected on COM3 or false otherwise" 
; (arduino-connect (make-arduino (list (make-motor 3 0.0)
;                                      (make-led 2 0)
;                                      (make-button 5 true))
;                                "com4"
;                                4800))
; "should return true if an arduino is connected on COM4 or false otherwise"
; (arduino-connect (make-arduino (list (make-motor 3 0.0)
;                                      (make-led 2 0)
;                                      (make-button 5 true)
;                                      (make-button 7 false))
;                                "com6"
;                                3200))
; "should return true if an arduino is connected on COM6 or false otherwise"


(define (arduino-connect an-arduino)
  (and 
   (eq? (system-type 'os) 'windows)
   (if (not (system (string-append  "mode " (arduino-com an-arduino) ": baud="
                                    (number->string BAUD) "parity=N data=8 stop=1")))
       false
       true)
   )
  (open-input-output-file PORT)
  )
  

;arduino-set-loop: arduino number . procs -> void
;given a CONNECTED! arduino, a number indicating timeout in seconds,
;and some procedures (variable arity)
;run each procedure on separate threads
;and kill the ones that exceed their timeout
; (arduino-set-loop (make-arduino (list (make-motor 3 0.0)
;                                       (make-led 2 0))
;                                 "com3"
;                                 9600)
;                   15
;                   (motor-set-speed (make-motor 3 0.0) 1.0))
; "should set the motor on port 3 to 1.0 and return true or timeout in 15 seconds and return false"
; (arduino-set-loop (make-arduino (list (make-motor 3 0.0)
;                                       (make-led 2 0))
;                                 "com3"
;                                 9600)
;                   15
;                   (motor-set-speed (make-motor 3 0.0) 1.0)
;                   (led-set (make-led 2 0) 1))
; "should set the motor on port 3 to 1.0, set the LED on, and return true or timeout in 15 seconds and return false"
; (arduino-set-loop (make-arduino (list (make-motor 3 0.0)
;                                       (make-led 2 0))
;                                 "com3"
;                                 9600)
;                   15
;                   (motor-run-at-speed (make-motor 3 0.0) 1.0 16))
; "should run the motor on port 3 at 1.0 for 15 seconds, and then time out and return false"

(define (arduino-set-loop an-arduino timeout . procs)
  (map (proc-helper) procs (build-list (length procs) (lambda (x) timeout)))
  )

;proc-helper: proc number -> boolean
;given a procedure and a timeout
;let the procedure run for the given timeout
;if it is completed after that time, return true
;otherwise, kill it and return false
(define (proc-helper proc timeout)
  ;start the thread
  (define thunk (thread proc))
  ;let the thread run in peace for the given time
  (sleep timeout)
  ;if the thread still exists, it hasn't completed within the timeout
  (not (thread? thunk))
  ;killing the thread won't return an error if the thread exists
  ; so we're good to go
  (kill-thread thunk)
  )

;arduino-read-analog: arduino number -> number
;given a CONNECTED! arduino and a number indicating an analog port (1-5 for the uno)
;return the analog read from that port
;(for easy testing, hook up a linear potentiameter [known as a linear pot for short])
; (arduino-read-analog (make-arduino (list (make-motor 3 0.0)
;                                      (make-led 2 0))
;                                "com3"
;                                9600)
;                      1010)
; "should return 0.0 if nothing is on port 3, or some value 0 - 1023 if a pot is wired to it"
; (arduino-read-analog (make-arduino (list (make-motor 3 0.0)
;                                      (make-led 2 0)
;                                      (make-button 5 true))
;                                "com4"
;                                4800)
;                      505)
; "should return 0.0 if nothing is on port 4, or some value 0 - 1023 if a pot is wired to it"
; (arduino-read-analog (make-arduino (list (make-motor 3 0.0)
;                                      (make-led 2 0)
;                                      (make-button 5 true)
;                                      (make-button 7 false))
;                                "com6"
;                                3200)
;                      200)
; "should return 0.0 if nothing is on port 5, or some value 0 - 1023 if a pot is wired to it"

(define (arduino-read-analog an-arduino port)
  (com-write (string-append port "#" "3" "#" "0"))
  (sleep .01)
  (com-read))

;arduino-read-digital: arduino number -> number
;given a CONNECTED! arduino and a number indicating an digital port (1-16 for the uno)
;return the digital read from that port (1 or 0)
;(for easy testing, hook up a digital-in)
; (arduino-read-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0))
;                                     "com3"
;                                     9600)
;                       3)
; "should return 0.0 if nothing is on port 3, or 1.0 if some digital in is wired to it"
; (arduino-read-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0)
;                                           (make-button 5 true))
;                                     "com4"
;                                     4800)
;                       4)
; "should return 0.0 if nothing is on port 4, or 1.0 if some digital in is wired to it"
; (arduino-read-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0)
;                                           (make-button 5 true)
;                                           (make-button 7 false))
;                                     "com6"
;                                     3200)
;                       5)
; "should return 0.0 if nothing is on port 5, or 1.0 if some digital in is wired to it"


(define (arduino-read-digital an-arduino port)
  (com-write (string-append port "#" "1" "#" "0"))
  (sleep .01)
  (com-read))

;arduino-write-digital: arduino number -> void
;given a CONNECTED! arduino and a number indicating an digital port (1-16 for the uno)
;write to that port (1)
; (arduino-write-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0))
;                                     "com3"
;                                     9600)
;                       3)
; "should return true and write to port 3"
; (arduino-write-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0)
;                                           (make-button 5 true))
;                                     "com4"
;                                     4800)
;                       4)
; "should return true and write to port 4"
; (arduino-write-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0)
;                                           (make-button 5 true)
;                                           (make-button 7 false))
;                                     "com6"
;                                     3200)
;                       5)
; "should return true and write to port 5"


(define (arduino-write-digital an-arduino port)
  (com-write (string-append port "#" "0" "#" "1")))

;arduino-write-analog: arduino number number-> void
;given a CONNECTED! arduino and a number indicating a pwm port and a value (0-255)
;write to that port the given value
; (arduino-write-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0))
;                                     "com3"
;                                     9600)
;                       3)
; "should return true and write to port 3"
; (arduino-write-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0)
;                                           (make-button 5 true))
;                                     "com4"
;                                     4800)
;                       4)
; "should return true and write to port 4"
; (arduino-write-digital (make-arduino (list (make-motor 3 0.0)
;                                           (make-led 2 0)
;                                           (make-button 5 true)
;                                           (make-button 7 false))
;                                     "com6"
;                                     3200)
;                       5)
; "should return true and write to port 5"


(define (arduino-write-analog an-arduino port val)
  (com-write (string-append port "#" "2" "#" val)))



;Demonstration arduino!

;uncomment the line below if you have an arduino to demo
(define-values (IN OUT) (arduino-connect (make-arduino (list (motor 3 0.0) (led 2 0)) "com3" 9600)))
