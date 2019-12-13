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
(define tGame2 '((4 na na 4 4)
                 (na 16 na 16 4)
                 (na na na 16 8)
                 (32 na 2 na 4)
                 (32 na na 16 8)))

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
(check-expect (draw-tiles tGame2) (list (draw-single-tile 4) BLANK-TILE BLANK-TILE
                                        (draw-single-tile 4) (draw-single-tile 4) BLANK-TILE
                                        (draw-single-tile 16) BLANK-TILE (draw-single-tile 16)
                                        (draw-single-tile 4) BLANK-TILE BLANK-TILE BLANK-TILE
                                        (draw-single-tile 16) (draw-single-tile 8)
                                        (draw-single-tile 32) BLANK-TILE (draw-single-tile 2)
                                        BLANK-TILE (draw-single-tile 4) (draw-single-tile 32)
                                        BLANK-TILE BLANK-TILE (draw-single-tile 16)
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
(define (key tG keyEvent)
  (cond [(key=? keyEvent "right") (combo-right (move-right tG))]
        [(key=? keyEvent "left") (combo-left (move-left tG))]
        [else tG]))

(check-expect (key tGame1 "l") tGame1)
(check-expect (key tGame1 "right")
              '((na na na na 8)
                (na na na 2 4)
                (na na na na 16)
                (na na na 2 4)
                (na na na 16 8)))
(check-expect (key tGame1 "left")
              '((8 na na na na)
                (2 4 na na na)
                (16 na na na na)
                (2 4 na na na)
                (16 8 na na na)))

; move-right : tGame -> tGame
; Move all tiles right if possible
(define (move-right tG)
  (map move-row-right tG))

(check-expect (move-right tGame1)
              '((na na na 4 4)
                (na na na 2 4)
                (na na na 8 8)
                (na na na 2 4)
                (na na na 16 8)))
(check-expect (move-right '((na na na 4 4)
                            (na 2 na na 4)
                            (8 8 na na na)
                            (na na na 2 4)
                            (16 na na 8 na)))
              '((na na na 4 4)
                (na na na 2 4)
                (na na na 8 8)
                (na na na 2 4)
                (na na na 16 8)))

; move-row-right : [List-of Tile] -> [List-of Tile]
; Slide tiles all the way to the right as is possible
(define (move-row-right row)
  (sort row (λ (tile1 tile2) (symbol? tile1))))

(check-expect (move-row-right empty) empty)
(check-expect (move-row-right '(na na na 4 4)) '(na na na 4 4))
(check-expect (move-row-right '(na 4 na 8 na)) '(na na na 4 8))
(check-expect (move-row-right '(16 na na na na)) '(na na na na 16))
(check-expect (move-row-right '(na na 8 4 na)) '(na na na 8 4))

; move-left : tGame -> tGame
; Move all tiles left if possible
(define (move-left tG)
  (map move-row-left tG))

(check-expect (move-left tGame1)
              '((4 4 na na na)
                (2 4 na na na)
                (8 8 na na na)
                (2 4 na na na)
                (16 8 na na na)))
(check-expect (move-left '((na na na 4 4)
                           (na 2 na na 4)
                           (8 8 na na na)
                           (na na na 2 4)
                           (16 na na 8 na)))
              '((4 4 na na na)
                (2 4 na na na)
                (8 8 na na na)
                (2 4 na na na)
                (16 8 na na na)))

; move-row-left : [List-of Tile] -> [List-of Tile]
; Slide tiles all the way to the left as is possible
(define (move-row-left row)
  (sort row (λ (tile1 tile2) (symbol? tile2))))

(check-expect (move-row-left empty) empty)
(check-expect (move-row-left '(na na na 4 4)) '(4 4 na na na))
(check-expect (move-row-left '(na 4 na 8 na)) '(4 8 na na na))
(check-expect (move-row-left '(16 na na na na)) '(16 na na na na))
(check-expect (move-row-left '(na na na na 16)) '(16 na na na na))
(check-expect (move-row-left '(na na 8 4 na)) '(8 4 na na na))

; combo-right : tGame -> tGame
; Combine values next to each other that are the same going right
(define (combo-right tG)
  (map combo-row-right tG))

(check-expect (combo-right tGame1)
              '((na na na na 8)
                (na na na 2 4)
                (na na na na 16)
                (na na 2 na 4)
                (na na na 16 8)))

; combo-row-right : [List-of Tile] -> [List-of Tile]
; Combine values next to each other that are the same going right
(define (combo-row-right row)
  (cond [(or (empty? row) (empty? (rest row))) row]
        [(cons? row) (if (and (number? (first row)) (number? (second row))
                              (= (first row) (second row)))
                         (cons 'na (combo-row-right (cons (+ (first row) (second row))
                                                          (rest (rest row)))))
                         (cons (first row) (combo-row-right (rest row))))]))

#;(check-expect (combo-row-right ...) ...)

; combo-left : tGame -> tGame
; Combine values next to each other that are the same going left
(define (combo-left tG)
  (map combo-row-left tG))

(check-expect (combo-left tGame1)
              '((na na na 8 na)
                (na na na 2 4)
                (na na na 16 na)
                (na na 2 na 4)
                (na na na 16 8)))

; combo-row-left : [List-of Tile] -> [List-of Tile]
; Combine values next to each other that are the same going left
(define (combo-row-left row)
  (cond [(or (empty? row) (empty? (rest row))) row]
        [(cons? row) (if (and (number? (first row)) (number? (second row))
                              (= (first row) (second row)))
                         (combo-row-left (cons (+ (first row) (second row))
                                               (append (rest (rest row)) '(na))))
                         (cons (first row) (combo-row-left (rest row))))]))

#;(check-expect (combo-row-left ...) ...)

; push-down-board : tGame -> tGame
; Pushes tiles all the way down as is possible
(define (push-down-board tG)
  
  (cond [(or (empty? tG) (empty? (rest tG))) tG]
        [(cons? tG) (cons (push-row-down-top (first tG) (second tG))
                          (push-down-board (cons (push-row-down-bot (first tG) (second tG))
                                                 (rest (rest tG)))))]))

(check-expect (push-down-board '((na na na 8 na)
                                 (na na na 2 4)
                                 (na na na 16 na)
                                 (na na 2 na 4)
                                 (na na na 16 8)))
              '((na na na na na)
                (na na na na na)
                (na na na 8 na)
                (na na na 2 na)
                (na na 2 32 16)))

; push-row-down-top : [List-of Tile] [List-of Tile] -> [List-of Tile]
; Return the result of the top row after having pushed values into the bottom row
(define (push-row-down-top top bot)
  (map (λ (tile-top tile-bot)
         (cond [(symbol? tile-bot) tile-bot]
               [(symbol? tile-top) tile-top]
               [(and (number? tile-top) (number? tile-bot) (= tile-top tile-bot)) 'na]
               [(and (number? tile-top) (number? tile-bot)) tile-top]))
       top
       bot))

(check-expect (push-row-down-top '(na na na na na) '(na na na na na)) '(na na na na na))
(check-expect (push-row-down-top '(na na na na na) '(na na na 4 na)) '(na na na na na))
(check-expect (push-row-down-top '(na na na na 4) '(na na na na na)) '(na na na na na))
(check-expect (push-row-down-top '(na na na na 4) '(na na na na 4)) '(na na na na na))
(check-expect (push-row-down-top '(na na na na 8) '(na na na na 4)) '(na na na na 8))

; push-row-down-bot : [List-of Tile] [List-of Tile] -> [List-of Tile]
; Return the result of the bottom row after having pushed values into the bottom row
(define (push-row-down-bot top bot)
  (map (λ (tile-top tile-bot)
         (cond [(symbol? tile-top) tile-bot]
               [(and (symbol? tile-bot) (number? tile-top)) tile-top]
               [(and (number? tile-top) (number? tile-bot) (= tile-top tile-bot))
                (+ tile-top tile-bot)]
               [(and (number? tile-top) (number? tile-bot)) tile-bot]))
       top
       bot))

(check-expect (push-row-down-bot '(na na na na na) '(na na na na na)) '(na na na na na))
(check-expect (push-row-down-bot '(na na na na na) '(na na na 4 na)) '(na na na 4 na))
(check-expect (push-row-down-bot '(na na na na 4) '(na na na na na)) '(na na na na 4))
(check-expect (push-row-down-bot '(na na na na 4) '(na na na na 4)) '(na na na na 8))
(check-expect (push-row-down-bot '(na na na na 4) '(na na na na 8)) '(na na na na 8))


; ------------------------------ Other Functions ------------------------------

; game-over? : tGame -> Boolean
; Is the game at either a win state or a loose state?
(define (game-over? tG)
  (or (win? tG) (loose? tG)))

(check-expect (game-over? tGame1) #f)
(check-expect (game-over? tGame2) #f)

; win? : tGame -> Boolean
; Does the board contain at least one 2048 tile?
(define (win? tG)
  (ormap (λ (row)
           (ormap (λ (tile) (and (number? tile) (= tile 2048)))
                  row))
         tG))

(check-expect (win? tGame1) #f)
(check-expect (win? tGame2) #f)
(check-expect (win? '((4 na na 4 4)
                      (na 16 na 16 4)
                      (na na 2048 16 8)
                      (32 na 2 na 4)
                      (32 na na 16 8)))
              #t)

; loose? : tGame -> Boolean
; Are the following conditions satisfied?
; - There are no empty spaces
; - No key press operation will change the tGame
; - None of the tiles are 2048
(define (loose? tG)
  (and (not (win? tG))
       (number? 'a)))

; no-empty-spaces? : tGame -> Boolean

; tGame=? : tGame tGame -> Boolean
; Are the given tGames identical?
(define (tGame=? tG1 tG2)
  (andmap (λ (row1 row2)
            (andmap (λ (tile1 tile2) (or (and (symbol? tile1) (symbol? tile2))
                                         (and (number? tile1) (number? tile2) (= tile1 tile2))))
                    row1
                    row2))
          tG1
          tG2))

(check-expect (tGame=? empty empty) #t)
(check-expect (tGame=? tGame1 tGame1) #t)
(check-expect (tGame=? tGame2 tGame2) #t)
(check-expect (tGame=? tGame1 tGame2) #f)
(check-expect (tGame=? tGame2 tGame1) #f)
          

; ----------------------------------- MAIN ------------------------------------
 
; main : tGame -> tGame
(define (main starter-board)
  (big-bang starter-board
    [to-draw draw]
    [on-key key]
    [stop-when game-over?]))