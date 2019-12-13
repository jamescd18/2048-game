;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname |2048 Game ISL+|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))


; 2048 Game?
; James Chang-Davidson

(require 2htdp/universe)
(require 2htdp/image)

; A Tile is on of:
; - a Number such that it is a power of 2 between 2 and 2048
; - 'na

; A tGame is a 5x5 [List-of [List-of Tile]]

; Example tGame:
(define tGame1 '((na na na 4 4)
                 (na na na 2 4)
                 (na na na 8 8)
                 (na na 2 na 4)
                 (na na na 16 8)))

; Constants
(define BG-COLOR "darkgrey")
(define TILE-COLOR "orange")
(define NUM-COLOR "white")
(define BG-SIZE 250)
(define TILE-SIZE 40)
(define NUM-SIZE 14)
(define BLANK-TILE (square TILE-SIZE "solid" "lightgrey"))

(define (p x y) (make-posn x y)) ; Simplifier shortcut
(define GRID-COORDS (list (p 25 25) (p 75 25) (p 125 25) (p 175 25) (p 225 25)
                          (p 25 75) (p 75 75) (p 125 75) (p 175 75) (p 225 75)
                          (p 25 125) (p 75 125) (p 125 125) (p 175 125) (p 225 125)
                          (p 25 175) (p 75 175) (p 125 175) (p 175 175) (p 225 175)
                          (p 25 225) (p 75 225) (p 125 225) (p 175 225) (p 225 225)))

;(build-list 5 (λ (n) (build-list 5 identity)))
#;(list (list 0 1 2 3 4)
        (list 0 1 2 3 4)
        (list 0 1 2 3 4)
        (list 0 1 2 3 4)
        (list 0 1 2 3 4))

; ------------------------------- Draw Functions -------------------------------

; draw : tGame -> Image
; Draws the current game state board
(define (draw tG)
  (place-images (draw-tiles tG)
                GRID-COORDS
                (square BG-SIZE "solid" BG-COLOR)))

(check-expect (draw tGame1) (place-images (draw-tiles tGame1)
                                          GRID-COORDS
                                          (square BG-SIZE "solid" BG-COLOR)))

; draw-tiles : tGame -> [List-of Image]
; Convert the board into a list of images for each tile
(define (draw-tiles tG)
  (map draw-single-tile (apply append tG)))

(check-expect (draw-tiles tGame1) (list BLANK-TILE BLANK-TILE BLANK-TILE (draw-single-tile 4)
                                        (draw-single-tile 4) BLANK-TILE BLANK-TILE BLANK-TILE
                                        (draw-single-tile 2) (draw-single-tile 4) BLANK-TILE
                                        BLANK-TILE BLANK-TILE (draw-single-tile 8)
                                        (draw-single-tile 8) BLANK-TILE BLANK-TILE
                                        (draw-single-tile 2) BLANK-TILE (draw-single-tile 4)
                                        BLANK-TILE BLANK-TILE BLANK-TILE (draw-single-tile 16)
                                        (draw-single-tile 8)))

; draw-single-tile : Tile -> Image
; Draws the given tile
(define (draw-single-tile t)
  (cond [(symbol? t) BLANK-TILE]
        [(number? t) (overlay/align 'center
                                    'center
                                    (text (number->string t) NUM-SIZE NUM-COLOR)
                                    (square TILE-SIZE "solid" TILE-COLOR))]))

(check-expect (draw-single-tile 'na) BLANK-TILE)
(check-expect (draw-single-tile 2) (overlay/align 'center 'center (text "2" NUM-SIZE NUM-COLOR)
                                                  (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 4) (overlay/align 'center 'center (text "4" NUM-SIZE NUM-COLOR)
                                                  (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 8) (overlay/align 'center 'center (text "8" NUM-SIZE NUM-COLOR)
                                                  (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 16) (overlay/align 'center 'center (text "16" NUM-SIZE NUM-COLOR)
                                                   (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 32) (overlay/align 'center 'center (text "32" NUM-SIZE NUM-COLOR)
                                                   (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 64) (overlay/align 'center 'center (text "64" NUM-SIZE NUM-COLOR)
                                                   (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 128) (overlay/align 'center 'center (text "128" NUM-SIZE NUM-COLOR)
                                                    (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 256) (overlay/align 'center 'center (text "256" NUM-SIZE NUM-COLOR)
                                                    (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 512) (overlay/align 'center 'center (text "512" NUM-SIZE NUM-COLOR)
                                                    (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 1024) (overlay/align 'center 'center (text "1024" NUM-SIZE NUM-COLOR)
                                                     (square TILE-SIZE "solid" TILE-COLOR)))
(check-expect (draw-single-tile 2048) (overlay/align 'center 'center (text "2048" NUM-SIZE NUM-COLOR)
                                                     (square TILE-SIZE "solid" TILE-COLOR)))


; ------------------------------- Key Functions -------------------------------

; key : KeyEvent tGame -> tGame
(define (key keyEvent tG)
  tG)

; ----------------------------------- MAIN ------------------------------------

; main : tGame -> tGame
(define (main starter-board)
  (big-bang starter-board
    [to-draw draw]
    [on-key key]))