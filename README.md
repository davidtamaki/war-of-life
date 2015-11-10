## Summary

Implements five AI strategies in war of life board game: random, bloodlust, self_preservation, land_grab, minimax.


## Play a match

Load war_of_life.pl and my_wol.pl into Prolog, then type the query:

* 'play(verbose, bloodlust, land_grab, NumberOfMoves, WinningPlayer)'

This will play a game in which player 1 uses the bloodlust strategy and player 2 uses the land_grab strategy.


## Play a tournament

To run a tournament, use the test_strategy_results query as follows with TotalGames, FirstPlayerStrategy, and SecondPlayerStrategy specified:

* 'test_strategy_results(N,TotalGames,FirstPlayerStrategy,SecondPlayerStrategy,
					Draws,FPWins,SPWins,NumMovesList,RunTimes)'

A summary of statistics will display the:
* Total games played
* Number of draws
* Number of exhausted games
* First player strategy (blue)
* Number of wins for player 1 (blue)
* Second player strategy (red)
* Number of wins for player 2 (red)
* Longest (non-exhaustive) game
* Shortest game
* Average game length (including exhaustives)
* Average game time (ms)
* Total testing time (ms)
* List of NumMoves

