;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname exercise_7) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require "./define_struct.rkt")
(require "./asteroids_lib.rkt")

; Asteroids implemented using methods

;;; Type definitions

;; This is the base type of all objects on screen.
;; However, this is an "abstract" type.  We will never say (make-game-object ...), we'll
;; make different *subtypes* of game-object.
(define-struct game-object
  (position velocity orientation rotational-velocity)
  #:methods
  ;; update!: game-object -> void
  ;; Update object for the next frame.
  ;; This is a default method; it will be used by any classes that don't
  ;; define their own update! method.
  (define (update! me)
    ;; Do nothing
    (void))
  
  ;; destroy!: game-object -> void
  ;; Destroys the game object
  ;; This is a default method; it will be used by any classes that don't
  ;; define their own destory! method.
  (define (destroy! me)
    (set! all-game-objects
          (remove me all-game-objects)))
  
  ;; render: game-object -> image
  ;; Draws the game-object.
  ;; There is no default method for render, since there is no default
  ;; appearance for objects.  You must fill in a render method for your
  ;; subclass.
  
  ;; radius: game-object -> number
  ;; Size of the game object for purposes of detecting collisions.
  ;; There is no default method for raidus, since there's no default
  ;; size for objects.  You must fill in a radius method for your
  ;; subclass.
  )

(check-satisfied update! procedure?)
(check-satisfied destroy! procedure?)

;; This is the type for the player's ship.
;; There will always be exactly one of these, and it will be stored
;; in the global variable the-player.
(define-struct (player game-object)
  ()
  #:methods
  ;; FILL IN THE FOLLOWING METHODS
  
  ;; update!: player -> void
  ;; Accelerate if the engines are firing.
  (define (update! p)
    (when firing-engines?
      (set-game-object-velocity! p
                                 (posn-+ (game-object-velocity p)
                                         (forward-direction p)))))
  
  
  ;; render: player -> image
  ;; Draw the player's ship

  (define (render p) (isosceles-triangle 20 50 "solid" "red"))
  ;; radius: player -> number
  ;; Size of the object (for collision detection)
  (define (radius p) 20)

  
  )

(check-satisfied
 (make-player (make-posn 400 300)
              (make-posn 0 0)
              0
              0)
 game-object?)
(check-satisfied render procedure?)
(check-satisfied radius procedure?)

;; This is the type for the asteroids.
;; Asteroids come in different sizes, so they have a radius
;; field in addition to their color field.
(define-struct (asteroid game-object)
  (radius color)
  #:methods
  ;; FILL THESE IN
  
  ;; render: asteroid -> image
  ;; Draw the asteroid
  (define (render a)
    (circle (asteroid-radius a) "solid" (asteroid-color a)))

  
  ;; radius: asteroid -> number
  ;; Size of the asteroid
  (define (radius a)
    (asteroid-radius a))
  )

(check-satisfied
 (make-asteroid (make-posn (random 800) (random 600))
                (random-velocity)
                0
                0
                (random-float 10 30)
                (random-color))
 game-object?)

;; This is the type for normal missiles.
(define-struct (missile game-object)
  (lifetime)
  #:methods
  ;; FILL THESE IN
  
  ;; update!: missile -> void
  ;; Decrement missile lifetime and destroy if necessary.
  (define (update! m)
    (if (> (missile-lifetime m) 0)
        (set-missile-lifetime! m (- (missile-lifetime m) 1))
        (destroy! m)))
  
  ;; render: missile -> image
  ;; Draw the missile
  (define (render m)
    (circle 10 "solid" "green"))
  ;; radius: missile -> number
  ;; Size of the missile
  (define (radius m) 10)
  
  )

(check-satisfied
 (make-missile (make-posn 420 350)
               (make-posn 5 3)
               0
               0
               100)
 game-object?)

;;
;; HEAT SEEKER MISSILE HERE
;;
(define-struct (heat-seeker missile)
  ()

  #:methods

;; update!: heat-seeker -> void
;; to let heat-seeker track down the closest asteroid around it and fly towards that
  (define (update! s)
    (when (not (equal? (closest-asteroid-to s) #false))
      (set-game-object-velocity! s
                                 (posn-+ (game-object-velocity s)
                                         (heading-of (closest-asteroid-to s)
                                                     s)))))
;; render: heat-seeker -> image
;; draw the heat-seeker
  (define (render s)
    (square 5 "solid" "blue"))
;; radius: heat-seeker -> number
;; size of the heat-seeker
  (define (radius s) 5)
    )
  




(check-satisfied make-heat-seeker procedure?)
(check-satisfied
 (make-heat-seeker (make-posn 420 350)
                   (make-posn 5 3)
                   0
                   0
                   100)
 missile?)

;;
;; UFO HERE
;;

(define-struct (ufo game-object)
  ()
  #:methods
  (define (update! u)
    (set-game-object-velocity! u
                               (posn-* 10
                                       (heading-of the-player u)
                                       )))


  (define (render u)
    (rectangle 20 10 "solid" "pink"))

  (define (radius u) 10)

  (define (destroy! u)
    (set-game-object-position! u
                               (make-posn 100 100))))

(check-satisfied make-ufo procedure?)
(check-satisfied
 (make-ufo (make-posn 400 300)
           (make-posn 0 0)
           0
           0)
 game-object?)

;;;
;;; Don't modify the code below
;;;

;;; Tracking game objects
(define all-game-objects '())
(check-satisfied all-game-objects list?)

;;; Main asteroids game
(define (asteroids)
  (link-and-start-asteroids-game))
