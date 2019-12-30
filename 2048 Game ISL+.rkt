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
(define tGame3 '((2 4 8 16 32)
                 (64 128 256 512 1024)
                 (2 4 8 16 32)
                 (64 128 256 512 4)
                 (2 4 8 16 32)))

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
  (cond [(key=? keyEvent "right") (push-right-board tG)]
        [(key=? keyEvent "left") (push-left-board tG)]
        [(key=? keyEvent "down") (push-down-board tG)]
        [(key=? keyEvent "up") (push-up-board tG)]
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
(check-expect (key tGame1 "down")
              '((na na na na na)
                (na na na 4 na)
                (na na na 2 16)
                (na na na 8 4)
                (na na 2 16 8)))
(check-expect (key tGame1 "up")
              '((na na 2 4 16)
                (na na na 2 4)
                (na na na 8 8)
                (na na na 16 na)
                (na na na na na)))
(check-expect (key tGame3 "right") tGame3)

; push-right-board : tGame -> tGame
; Pushes tiles all the way right as is possible
(define (push-right-board tG)
  (local [(define next-board (combo-right (move-right tG)))]
    (if (tGame=? tG next-board)
        tG
        (push-right-board next-board))))

(check-expect (push-right-board tGame1)
              '((na na na na 8)
                (na na na 2 4)
                (na na na na 16)
                (na na na 2 4)
                (na na na 16 8)))
(check-expect (push-right-board tGame2)
              '((na na na 8 4)
                (na na na 32 4)
                (na na na 16 8)
                (na na 32 2 4)
                (na na 32 16 8)))
(check-expect (push-right-board '((na na na na na)
                                  (na na na na na)
                                  (na na na na na)
                                  (na na na na na)
                                  (16 16 16 16 16)))
              '((na na na na na)
                (na na na na na)
                (na na na na na)
                (na na na na na)
                (na na na 64 16)))
(check-expect (push-right-board tGame3) tGame3)

; push-left-board : tGame -> tGame
; Pushes tiles all the way left as is possible
(define (push-left-board tG)
  (local [(define next-board (combo-left (move-left tG)))]
    (if (tGame=? tG next-board)
        tG
        (push-left-board next-board))))

(check-expect (push-left-board tGame1)
              '((8 na na na na)
                (2 4 na na na)
                (16 na na na na)
                (2 4 na na na)
                (16 8 na na na)))
(check-expect (push-left-board tGame2)
              '((8 4 na na na)
                (32 4 na na na)
                (16 8 na na na)
                (32 2 4 na na)
                (32 16 8 na na)))
(check-expect (push-left-board '((na na na na na)
                                 (na na na na na)
                                 (na na na na na)
                                 (na na na na na)
                                 (16 16 16 16 16)))
              '((na na na na na)
                (na na na na na)
                (na na na na na)
                (na na na na na)
                (64 16 na na na)))
(check-expect (push-left-board tGame3) tGame3)

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
(check-expect (move-right tGame3) tGame3)

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
(check-expect (move-left tGame3) tGame3)

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
(check-expect (combo-right tGame2)
              '((4 na na na 8)
                (na 16 na 16 4)
                (na na na 16 8)
                (32 na 2 na 4)
                (32 na na 16 8)))
(check-expect (combo-right tGame3) tGame3)

; combo-row-right : [List-of Tile] -> [List-of Tile]
; Combine values next to each other that are the same going right
(define (combo-row-right row)
  (cond [(or (empty? row) (empty? (rest row))) row]
        [(cons? row) (if (and (number? (first row)) (number? (second row))
                              (= (first row) (second row)))
                         (cons 'na (combo-row-right (cons (+ (first row) (second row))
                                                          (rest (rest row)))))
                         (cons (first row) (combo-row-right (rest row))))]))

(check-expect (combo-row-right '(na na na na na)) '(na na na na na))
(check-expect (combo-row-right '(8 na na na 16)) '(8 na na na 16))
(check-expect (combo-row-right '(na na na 4 4)) '(na na na na 8))
(check-expect (combo-row-right '(2 2 na 16 16)) '(na 4 na na 32))
(check-expect (combo-row-right '(na na 16 16 16)) '(na na na 32 16))
(check-expect (combo-row-right '(na 16 16 16 16)) '(na na 32 na 32))

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
(check-expect (combo-left tGame2)
              '((4 na na 8 na)
                (na 16 na 16 4)
                (na na na 16 8)
                (32 na 2 na 4)
                (32 na na 16 8)))
(check-expect (combo-left tGame3) tGame3)

; combo-row-left : [List-of Tile] -> [List-of Tile]
; Combine values next to each other that are the same going left
(define (combo-row-left row)
  (cond [(or (empty? row) (empty? (rest row))) row]
        [(cons? row) (if (and (number? (first row)) (number? (second row))
                              (= (first row) (second row)))
                         (combo-row-left (cons (+ (first row) (second row))
                                               (cons 'na (rest (rest row)))))
                         (cons (first row) (combo-row-left (rest row))))]))

(check-expect (combo-row-left '(na na na na na)) '(na na na na na))
(check-expect (combo-row-left '(8 na na na 16)) '(8 na na na 16))
(check-expect (combo-row-left '(na na na 4 4)) '(na na na 8 na))
(check-expect (combo-row-left '(2 2 na 16 16)) '(4 na na 32 na))
(check-expect (combo-row-left '(na na 16 16 16)) '(na na 32 na 16))
(check-expect (combo-row-left '(na 16 16 16 16)) '(na 32 na 32 na))

; push-down-board : tGame -> tGame
; Pushes tiles all the way down as is possible
(define (push-down-board tG)
  (if (tGame=? tG (push-down-board/one tG))
      tG
      (push-down-board (push-down-board/one tG))))

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
(check-expect (push-down-board tGame1)
              '((na na na na na)
                (na na na 4 na)
                (na na na 2 16)
                (na na na 8 4)
                (na na 2 16 8)))
(check-expect (push-down-board tGame2)
              '((na na na na na)
                (na na na na na)
                (na na na 4 16)
                (4 na na 32 4)
                (64 16 2 16 8)))
(check-expect (push-down-board tGame3) tGame3)

; push-down-board/one : tGame -> tGame
; Pushes tiles down as is possible one pass down
(define (push-down-board/one tG)
  (cond [(or (empty? tG) (empty? (rest tG))) tG]
        [(cons? tG) (cons (push-row-down-top (first tG) (second tG))
                          (push-down-board/one (cons (push-row-down-bot (first tG) (second tG))
                                                     (rest (rest tG)))))]))

(check-expect (push-down-board/one '((na na na 8 na)
                                     (na na na 2 4)
                                     (na na na 16 na)
                                     (na na 2 na 4)
                                     (na na na 16 8)))
              (list (list 'na 'na 'na 8 'na)
                    (list 'na 'na 'na 2 'na)
                    (list 'na 'na 'na 'na 'na)
                    (list 'na 'na 'na 'na 'na)
                    (list 'na 'na 2 32 16)))
(check-expect (push-down-board/one tGame1)
              '((na na na 4 na)
                (na na na 2 na)
                (na na na na 16)
                (na na na 8 4)
                (na na 2 16 8)))
(check-expect (push-down-board/one tGame2)
              '((na na na 4 na)
                (na na na na na)
                (4 na na na 16)
                (na na na 32 4)
                (64 16 2 16 8)))
(check-expect (push-down-board/one tGame3) tGame3)

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

; push-up-board : tGame -> tGame
; Pushes tiles all the way up as is possible
(define (push-up-board tG)
  (if (tGame=? tG (push-up-board/one tG))
      tG
      (push-up-board (push-up-board/one tG))))

(check-expect (push-up-board '((na na na 8 na)
                               (na na na 2 4)
                               (na na na 16 na)
                               (na na 2 na 4)
                               (na na na 16 8)))
              '((na na 2 8 16)
                (na na na 2 na)
                (na na na 32 na)
                (na na na na na)
                (na na na na na)))
(check-expect (push-up-board tGame1)
              '((na na 2 4 16)
                (na na na 2 4)
                (na na na 8 8)
                (na na na 16 na)
                (na na na na na)))
(check-expect (push-up-board tGame2)
              '((4 16 2 4 16)
                (64 na na 32 4)
                (na na na 16 8)
                (na na na na na)
                (na na na na na)))
(check-expect (push-up-board tGame3) tGame3)

; push-up-board/one : tGame -> tGame
; Pushes tiles up as is possible one pass up
(define (push-up-board/one tG)
  (cond [(or (empty? tG) (empty? (rest tG))) tG]
        [(cons? tG) (cons (push-row-up-top (first tG) (second tG))
                          (push-up-board/one (cons (push-row-up-bot (first tG) (second tG))
                                                   (rest (rest tG)))))]))

(check-expect (push-up-board/one '((na na na 8 na)
                                   (na na na 2 4)
                                   (na na na 16 na)
                                   (na na 2 na 4)
                                   (na na na 16 8)))
              '((na na na 8 4)
                (na na na 2 na)
                (na na 2 16 4)
                (na na na 16 8)
                (na na na na na)))
(check-expect (push-up-board/one tGame1)
              '((na na na 4 8)
                (na na na 2 8)
                (na na 2 8 4)
                (na na na 16 8)
                (na na na na na)))
(check-expect (push-up-board/one tGame2)
              '((4 16 na 4 8)
                (na na na 32 8)
                (32 na 2 na 4)
                (32 na na 16 8)
                (na na na na na)))
(check-expect (push-up-board/one tGame3) tGame3)

; push-row-up-top : [List-of Tile] [List-of Tile] -> [List-of Tile]
; Return the result of the top row after having pushed values into the top row
(define (push-row-up-top top bot)
  (map (λ (tile-top tile-bot)
         (cond [(symbol? tile-bot) tile-top]
               [(symbol? tile-top) tile-bot]
               [(and (number? tile-top) (number? tile-bot) (= tile-top tile-bot))
                (+ tile-top tile-bot)]
               [(and (number? tile-top) (number? tile-bot)) tile-top]))
       top
       bot))

(check-expect (push-row-up-top '(na na na na na) '(na na na na na)) '(na na na na na))
(check-expect (push-row-up-top '(na na na na na) '(na na na 4 na)) '(na na na 4 na))
(check-expect (push-row-up-top '(na na na na 4) '(na na na na na)) '(na na na na 4))
(check-expect (push-row-up-top '(na na na na 4) '(na na na na 4)) '(na na na na 8))
(check-expect (push-row-up-top '(na na na na 8) '(na na na na 4)) '(na na na na 8))

; push-row-up-bot : [List-of Tile] [List-of Tile] -> [List-of Tile]
; Return the result of the bottom row after having pushed values into the top row
(define (push-row-up-bot top bot)
  (map (λ (tile-top tile-bot)
         (cond [(or (symbol? tile-top) (symbol? tile-bot)
                    (and (number? tile-top) (number? tile-bot) (= tile-top tile-bot))) 'na]
               [(and (number? tile-top) (number? tile-bot)) tile-bot]))
       top
       bot))

(check-expect (push-row-up-bot '(na na na na na) '(na na na na na)) '(na na na na na))
(check-expect (push-row-up-bot '(na na na na na) '(na na na 4 na)) '(na na na na na))
(check-expect (push-row-up-bot '(na na na na 4) '(na na na na na)) '(na na na na na))
(check-expect (push-row-up-bot '(na na na na 4) '(na na na na 4)) '(na na na na na))
(check-expect (push-row-up-bot '(na na na na 4) '(na na na na 8)) '(na na na na 8))

; ----------------------------- New Tile Functions ----------------------------

; add-new-tile : tGame -> tGame
; Add a new number tile to a random empty tile in the board
(define (add-new-tile tG)
  (local [(define count-empty-tiles (- 25 (count-num-tiles tG)))]
    (if (= count-empty-tiles 0)
        tG
        (insert-new-tile (random count-empty-tiles) (get-new-tile (random 2048)) tG))))

(check-expect (count-num-tiles (add-new-tile tGame1)) 11)
(check-expect (count-num-tiles (add-new-tile tGame2)) 15)
(check-expect (count-num-tiles (add-new-tile tGame3)) 25)

; insert-new-tile : Integer Tile [NEList-of [List-of Tile]] -> [NEList-of [List-of Tile]]
; Insert the new tile into the correct row properly
(define (insert-new-tile new-tile-index new-tile tGame)
  (local [(define row-empty-tile-count (- 5 (count-num-tiles-row (first tGame))))]
    (cond [(empty? (rest tGame)) (list (insert-new-tile-row new-tile-index new-tile (first tGame)))]
          [(>= new-tile-index row-empty-tile-count)
           (cons (first tGame) (insert-new-tile (- new-tile-index row-empty-tile-count) new-tile
                                                (rest tGame)))]
          [(< new-tile-index row-empty-tile-count)
           (cons (insert-new-tile-row new-tile-index new-tile (first tGame))
                 (rest tGame))])))

(check-expect (insert-new-tile 0 2 '((na na na 2 8)
                                     (na na 4 na 8)
                                     (8 na 2 16 na)))
              '((2 na na 2 8)
                (na na 4 na 8)
                (8 na 2 16 na)))
(check-expect (insert-new-tile 1 2 '((na na na 2 8)
                                     (na na 4 na 8)
                                     (8 na 2 16 na)))
              '((na 2 na 2 8)
                (na na 4 na 8)
                (8 na 2 16 na)))
(check-expect (insert-new-tile 5 2 '((na na na 2 8)
                                     (na na 4 na 8)
                                     (8 na 2 16 na)))
              '((na na na 2 8)
                (na na 4 2 8)
                (8 na 2 16 na)))
(check-expect (insert-new-tile 6 2 '((na na na 2 8)
                                     (na na 4 na 8)
                                     (8 na 2 16 na)))
              '((na na na 2 8)
                (na na 4 na 8)
                (8 2 2 16 na)))
(check-expect (insert-new-tile 7 2 '((na na na 2 8)
                                     (na na 4 na 8)
                                     (8 na 2 16 na)))
              '((na na na 2 8)
                (na na 4 na 8)
                (8 na 2 16 2)))

; insert-new-tile-row : Integer Tile [List-of Tile] -> [List-of Tile]
; Insert the new tile into the correct spot in the list
(define (insert-new-tile-row new-tile-index new-tile row)
  (map (λ (tile index)
         (if (and (number? index) (= index new-tile-index))
             new-tile
             tile))
       row
       (build-empty-indecies 0 row)))

(check-expect (insert-new-tile-row 0 2 '(na na na 4 8)) '(2 na na 4 8))
(check-expect (insert-new-tile-row 1 4 '(na na na 4 8)) '(na 4 na 4 8))
(check-expect (insert-new-tile-row 2 8 '(na na na 4 8)) '(na na 8 4 8))

; build-empty-indecies : Integer [List-of Tile] -> [List-of [Maybe Integer]]
; Convert a list of tiles into indexed 'na s and #f for numbers
(define (build-empty-indecies na-so-far row)
  (cond [(empty? row) row]
        [(cons? row) (if (symbol? (first row))
                         (cons na-so-far (build-empty-indecies (add1 na-so-far) (rest row)))
                         (cons #f (build-empty-indecies na-so-far (rest row))))]))

(check-expect (build-empty-indecies 0 '(na na na na na)) '(0 1 2 3 4))
(check-expect (build-empty-indecies 0 '(na 2 na na na)) '(0 #f 1 2 3))
(check-expect (build-empty-indecies 0 '(na na na 4 8)) '(0 1 2 #f #f))
(check-expect (build-empty-indecies 0 '(16 na 32 na 1024)) '(#f 0 #f 1 #f))
(check-expect (build-empty-indecies 0 '(16 na 32 2 1024)) '(#f 0 #f #f #f))
(check-expect (build-empty-indecies 0 '(16 32 64 128 256)) '(#f #f #f #f #f))

; get-new-tile : Integer -> Integer
; Returns a new numer to be a tile based on the random number given
(define (get-new-tile rand-num)
    (cond [(= rand-num 2047) 2048] ; 1
          [(<= 2045 rand-num 2047) 1024] ; 2
          [(<= 2041 rand-num 2045) 512] ; 4
          [(<= 2033 rand-num 2041) 256] ; 8
          [(<= 2017 rand-num 2033) 128] ; 16
          [(<= 1985 rand-num 2017) 64] ; 32
          [(<= 1921 rand-num 1985) 32] ; 64
          [(<= 1793 rand-num 1921) 16] ; 128
          [(<= 1537 rand-num 1793) 8] ; 256
          [(<= 1025 rand-num 1537) 4] ; 512
          [(<= 0 rand-num 1025) 2])) ; 1024

(check-expect (number? (get-new-tile (random 2048))) #t)
(check-expect (integer? (log (get-new-tile (random 2048)) 2)) #t)
(check-expect (get-new-tile 2047) 2048)
(check-expect (get-new-tile 2046) 1024)
(check-expect (get-new-tile 2044) 512)
(check-expect (get-new-tile 2035) 256)
(check-expect (get-new-tile 2020) 128)
(check-expect (get-new-tile 2000) 64)
(check-expect (get-new-tile 1950) 32)
(check-expect (get-new-tile 1800) 16)
(check-expect (get-new-tile 1600) 8)
(check-expect (get-new-tile 1200) 4)
(check-expect (get-new-tile 500) 2)

; count-num-tiles : tGame -> Natural
; Count the number of non-empty tiles on the board
(define (count-num-tiles tG)
  (foldr (λ (row tot-so-far) (+ (count-num-tiles-row row) tot-so-far))
         0
         tG))

(check-expect (count-num-tiles tGame1) 10)
(check-expect (count-num-tiles tGame2) 14)
(check-expect (count-num-tiles tGame3) 25)


; count-num-tiles-row : [List-of Tile] -> Natural
; Count the number of non-empty tiles in a list
(define (count-num-tiles-row row)
  (foldr (λ (tile tot-row-so-far)
           (if (number? tile)
               (add1 tot-row-so-far)
               tot-row-so-far))
         0
         row))

(check-expect (count-num-tiles-row '(na na na na na)) 0)
(check-expect (count-num-tiles-row '(na na na 8 na)) 1)
(check-expect (count-num-tiles-row '(4 na na na 2)) 2)
(check-expect (count-num-tiles-row '(8 4 na na 16)) 3)
(check-expect (count-num-tiles-row '(128 256 64 512 na)) 4)
(check-expect (count-num-tiles-row '(2 4 8 16 32)) 5)

; ------------------------------ Other Functions ------------------------------

; game-over? : tGame -> Boolean
; Is the game at either a win state or a loose state?
(define (game-over? tG)
  (or (win? tG) (loose? tG)))

(check-expect (game-over? tGame1) #f)
(check-expect (game-over? tGame2) #f)
(check-expect (game-over? tGame3) #t)

; win? : tGame -> Boolean
; Does the board contain at least one 2048 tile?
(define (win? tG)
  (ormap (λ (row)
           (ormap (λ (tile) (and (number? tile) (= tile 2048)))
                  row))
         tG))

(check-expect (win? tGame1) #f)
(check-expect (win? tGame2) #f)
(check-expect (win? tGame3) #f)
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
  (and (board-full? tG)
       (tGame=? tG (key tG "up"))
       (tGame=? tG (key tG "down"))
       (tGame=? tG (key tG "left"))
       (tGame=? tG (key tG "right"))
       (not (win? tG))))

(check-expect (loose? tGame1) #f)
(check-expect (loose? tGame2) #f)
(check-expect (loose? tGame3) #t)

; board-full? : tGame -> Boolean
; Are there no empty spaces in the board?
(define (board-full? tG)
  (andmap (λ (row)
            (andmap (λ (tile)
                      (number? tile))
                    row))
          tG))

(check-expect (board-full? tGame1) #f)
(check-expect (board-full? tGame2) #f)
(check-expect (board-full? tGame3) #t)
(check-expect (board-full? '((4 4 4 4 4)
                             (4 4 4 4 4)
                             (4 4 4 4 4)
                             (4 4 4 4 4)
                             (4 4 4 4 4)))
              #t)

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
(check-expect (tGame=? tGame3 tGame1) #f)

; ----------------------------------- MAIN ------------------------------------
 
; main : tGame -> tGame
(define (main starter-board)
  (big-bang starter-board
    [to-draw draw]
    [on-key (compose add-new-tile key)]
    [stop-when game-over?]))

; nice tests:
; (main tGame1)
; (main tGame2)