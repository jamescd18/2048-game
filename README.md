This is my attempt at creating the simple yet popular game 2048 in Dr. Racket's ISL+ teaching language. 

The game rules and visual design are recreated from my memory and by no means a perfect replica. Design Recipe methodology from the How To Design Programs textbook are attempted in structuring the code.

After consulting someone that knows the game better and has played it siginificantly more than I have, I have come to the realization that the game logic I have coded is distinctly different from that of the real game. I have chosen to continue with my current interpretation, as I feel it will yield interesting and fun results.

Of note about my version:
- One key press operation will collapse numbers until they can no longer be collapsed further
- The game board is 5 by 5 rather than the original 4 by 4
- When a new tile is added with each key press, the new tile is randomly generated with a 1 out of 2048 chance of being a 2048, and doubling probabilities as the number is halved. (The new tile can be any valid number from 2048 to 2, but smaller numbers are more common)
