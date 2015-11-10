/* Part 1 - Test Strategy Results */ 

%%%%%% test_strategy/3
test_strategy(N,FirstPlayerStrategy,SecondPlayerStrategy):-
	test_strategy_results(N,N,FirstPlayerStrategy,SecondPlayerStrategy,0,0,0,[],[]).


%%%%%% test_strategy/7
test_strategy_results(N,TotalGames,FirstPlayerStrategy,SecondPlayerStrategy,
					Draws,FPWins,SPWins,NumMovesList,RunTimes):-
	N>0,
	statistics(runtime,[T0|_]),
	play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, NumMoves, WinningPlayer),
	statistics(runtime,[T1|_]),
	show_winner(quiet, WinningPlayer, NumMoves),
	T is T1-T0,
	NewN is N-1,
	calc_results(WinningPlayer,Draws,FPWins,SPWins,NewDraws,NewFPWins,NewSPWins),
	append([T],RunTimes,NewRunTimes),
	(NumMoves\=250->
		append([NumMoves],NumMovesList,NewNML),
		test_strategy_results(NewN,TotalGames,FirstPlayerStrategy,SecondPlayerStrategy,
						NewDraws,NewFPWins,NewSPWins,NewNML,NewRunTimes)
	;
		test_strategy_results(NewN,TotalGames,FirstPlayerStrategy,SecondPlayerStrategy,
					NewDraws,NewFPWins,NewSPWins,NumMovesList,NewRunTimes)).


%%%%%% test_strategy/7 (print final result)
test_strategy_results(0,TG,FPS,SPS,Draws,FPWins,SPWins,NML,RunTimes):-
	TotalExhausted is TG-FPWins-SPWins-Draws,
	calc_game_stats(NML,TotalExhausted,LongestG,ShortestG,AvgG,
				Sorted,AvgGTime,RunTimes,TotalRunTime,TG),
	format('Total games played: ~w ~n', [TG]),
	format('Number of draws: ~w ~n', [Draws]),
	format('Number of exhausted games: ~w ~n', [TotalExhausted]),
	format('First player strategy (blue): ~w ~n', [FPS]),
	format('Number of wins for player 1 (blue): ~w ~n', [FPWins]),
	format('Second player strategy (red): ~w ~n', [SPS]),
	format('Number of wins for player 2 (red): ~w ~n', [SPWins]),
	format('Longest (non-exhaustive) game: ~w ~n', [LongestG]),
	format('Shortest game: ~w ~n', [ShortestG]),
	format('Average game length (including exhaustives): ~w ~n', [AvgG]),
	format('Average game time (ms): ~w ~n', [AvgGTime]),
	format('Total testing time (ms): ~w ~n', [TotalRunTime]),
	format('List of NumMoves: ~w ~n', [Sorted]).


%%%%%% calc_results/7 (running sum totals for wins and draws)
calc_results('b',D,FPWins,SP,D,NewFPWins,SP):-
	NewFPWins is FPWins + 1.
calc_results('r',D,FP,SPWins,D,FP,NewSPWins):-
	NewSPWins is SPWins + 1.
calc_results('draw',Draw,FP,SP,NewDraw,FP,SP):-
	NewDraw is Draw + 1.
calc_results('stalemate',Draw,FP,SP,NewDraw,FP,SP):-
	NewDraw is Draw + 1.
calc_results('exhaust',Draw,FP,SP,Draw,FP,SP).


%%%%%% calc_game_stats/6 (calculate longest, shortest, average of games)
calc_game_stats(NML,TotalExhausted,LongestG,ShortestG,AvgG,Sorted,AvgGTime,RunTimes,TotalRunTime,TG):-
	bubble_sort(NML,Sorted),
	append([ShortestG|_],[_,LongestG],Sorted),
	sum_list(NML,SumL),
	TopUp is TotalExhausted*250,
	TotalMoves is SumL + TopUp,
	AvgG is TotalMoves/TG,
	sum_list(RunTimes,TotalRunTime),
	AvgGTime is TotalRunTime/TG.


%%%%%% bubble_sort/2 (sorting games for stats)
bubble_sort(L,Sorted):-
	b_sort(L,[],Sorted).
b_sort([],Acc,Acc).
b_sort([H|Tail],Acc,Sorted):-
	bubble(H,Tail,NewTail,Max),b_sort(NewTail,[Max|Acc],Sorted).
   
bubble(X,[],[],X).
bubble(X,[Y|Tail],[Y|NewTail],Max):-
	X>Y,bubble(X,Tail,NewTail,Max).
bubble(X,[Y|Tail],[X|NewTail],Max):-
	X=<Y,bubble(Y,Tail,NewTail,Max).

%%%%%% sum_list/2 (sum of list)
sum_list([], 0).
sum_list([H|Tail], Sum) :-
	sum_list(Tail, Rest),
	Sum is H + Rest.




/* Part 2 - Implementing Strategies */

%%%%%% helper predicates min,max, and find index of elements in list
max_e_list([H],H).
max_e_list([H,K|Tail],M):-
	H=<K,
	max_e_list([K|Tail],M).
max_e_list([H,K|Tail],M) :-
	H>K,
	max_e_list([H|Tail],M). 

min_e_list([H],H).
min_e_list([H,K|Tail],M):-
	H=<K,
	min_e_list([H|Tail],M).
min_e_list([H,K|Tail],M) :-
	H>K,
	min_e_list([K|Tail],M). 

index([E|_], E, 0).
index([_|Tail],E,Index):-
	index(Tail,E,Index1),
	Index is Index1+1.

%%%%%% list all possible moves for a player
poss_moves_blue([AliveBlues,AliveReds],PossMoves):-
	 findall([A,B,MA,MB],(member([A,B],AliveBlues),
                      neighbour_position(A,B,[MA,MB]),
	              \+member([MA,MB],AliveBlues),
	              \+member([MA,MB],AliveReds)),
	 PossMoves).

poss_moves_red([AliveBlues,AliveReds],PossMoves):-
	 findall([A,B,MA,MB],(member([A,B],AliveReds),
                      neighbour_position(A,B,[MA,MB]),
	              \+member([MA,MB],AliveReds),
	              \+member([MA,MB],AliveBlues)),
	 PossMoves).


%%%%%% BLOODLUST STRATEGY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bloodlust('b',[AliveBlues,AliveReds],[NewAliveBlues,AliveReds], Move):-
	bloodlust_move('b',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveBlues,NewAliveBlues).

bloodlust('r',[AliveBlues,AliveReds],[AliveBlues,NewAliveReds], Move):-
	bloodlust_move('r',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveReds,NewAliveReds).


bloodlust_move('b',[AliveBlues,AliveReds], Move) :-
	poss_moves_blue([AliveBlues,AliveReds],PossMoves),
	length(AliveReds,EnemyCount),
	get_bloodlust_score('b',PossMoves,[AliveBlues,AliveReds],[],EnemyCount,Index),
	index(PossMoves,Move,Index).

bloodlust_move('r',[AliveBlues,AliveReds], Move) :-
	poss_moves_red([AliveBlues,AliveReds],PossMoves),
	length(AliveBlues,EnemyCount),
	get_bloodlust_score('r',PossMoves,[AliveBlues,AliveReds],[],EnemyCount,Index),
	index(PossMoves,Move,Index).


%%%%%% BLOODLUST SCORE/6 (Player,PossMoves,BoardState,Scores,EnemyCount,Index)
get_bloodlust_score('b',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,EnemyCount,Index) :-
	alter_board(HPossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[_,CCNewAliveReds]), 
 	length(CCNewAliveReds,RL),
	ThisScore is EnemyCount - RL,
	append(Scores,[ThisScore],NewScores),
	get_bloodlust_score('b',TailPossMove,[AliveBlues,AliveReds],NewScores,EnemyCount,Index).

get_bloodlust_score('b',[PossMove],[AliveBlues,AliveReds],Scores,EnemyCount,Index) :-
	alter_board(PossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[_,CCNewAliveReds]),
 	length(CCNewAliveReds,RL),
	ThisScore is EnemyCount - RL,
	append(Scores,[ThisScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('BL: List of Scores: ~w ~n', [NewScores]),
	%format('BL: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).


get_bloodlust_score('r',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,EnemyCount,Index) :-
	alter_board(HPossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,_]), 
 	length(CCNewAliveBlues,BL),
	ThisScore is EnemyCount - BL,
	append(Scores,[ThisScore],NewScores),
	get_bloodlust_score('r',TailPossMove,[AliveBlues,AliveReds],NewScores,EnemyCount,Index).

get_bloodlust_score('r',[PossMove],[AliveBlues,AliveReds],Scores,EnemyCount,Index) :-
	alter_board(PossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,_]),
 	length(CCNewAliveBlues,BL),
	ThisScore is EnemyCount - BL,
	append(Scores,[ThisScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('BL: List of Scores: ~w ~n', [NewScores]),
	%format('BL: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).



%%%%%% SELF PRESERVATION STRATEGY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

self_preservation('b',[AliveBlues,AliveReds],[NewAliveBlues,AliveReds], Move):-
	self_preservation_move('b',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveBlues,NewAliveBlues).

self_preservation('r',[AliveBlues,AliveReds],[AliveBlues,NewAliveReds], Move):-
	self_preservation_move('r',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveReds,NewAliveReds).


self_preservation_move('b',[AliveBlues,AliveReds], Move) :-
	poss_moves_blue([AliveBlues,AliveReds],PossMoves),
	length(AliveBlues,MyCount),
	get_self_preservation_score('b',PossMoves,[AliveBlues,AliveReds],[],MyCount,Index),
	index(PossMoves,Move,Index).

self_preservation_move('r',[AliveBlues,AliveReds], Move) :-
	poss_moves_red([AliveBlues,AliveReds],PossMoves),
	length(AliveReds,MyCount),
	get_self_preservation_score('r',PossMoves,[AliveBlues,AliveReds],[],MyCount,Index),
	index(PossMoves,Move,Index).


%%%%%% SELF PRESERVATION SCORE/6 (Player,PossMoves,BoardState,Scores,MyCount,Index)
get_self_preservation_score('b',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,MyCount,Index) :-
	alter_board(HPossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[CCNewAliveBlues,_]), 
 	length(CCNewAliveBlues,BL),
	ThisScore is BL - MyCount,
	append(Scores,[ThisScore],NewScores),
	get_self_preservation_score('b',TailPossMove,[AliveBlues,AliveReds],NewScores,MyCount,Index).

get_self_preservation_score('b',[PossMove],[AliveBlues,AliveReds],Scores,MyCount,Index) :-
	alter_board(PossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[CCNewAliveBlues,_]),
 	length(CCNewAliveBlues,BL),
	ThisScore is BL - MyCount,
	append(Scores,[ThisScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('SP: List of Scores: ~w ~n', [NewScores]),
	%format('SP: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).


get_self_preservation_score('r',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,MyCount,Index) :-
	alter_board(HPossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[_,CCNewAliveReds]), 
 	length(CCNewAliveReds,RL),
	ThisScore is RL - MyCount,
	append(Scores,[ThisScore],NewScores),
	get_self_preservation_score('r',TailPossMove,[AliveBlues,AliveReds],NewScores,MyCount,Index).

get_self_preservation_score('r',[PossMove],[AliveBlues,AliveReds],Scores,MyCount,Index) :-
	alter_board(PossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[_,CCNewAliveReds]),
 	length(CCNewAliveReds,RL),
	ThisScore is RL - MyCount,
	append(Scores,[ThisScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('SP: List of Scores: ~w ~n', [NewScores]),
	%format('SP: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).



%%%%%% LAND GRAB STRATEGY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

land_grab('b',[AliveBlues,AliveReds],[NewAliveBlues,AliveReds], Move):-
	land_grab_move('b',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveBlues,NewAliveBlues).

land_grab('r',[AliveBlues,AliveReds],[AliveBlues,NewAliveReds], Move):-
	land_grab_move('r',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveReds,NewAliveReds).


land_grab_move('b',[AliveBlues,AliveReds], Move) :-
	poss_moves_blue([AliveBlues,AliveReds],PossMoves),
	get_land_grab_score('b',PossMoves,[AliveBlues,AliveReds],[],Index,_),
	index(PossMoves,Move,Index).

land_grab_move('r',[AliveBlues,AliveReds], Move) :-
	poss_moves_red([AliveBlues,AliveReds],PossMoves),
	get_land_grab_score('r',PossMoves,[AliveBlues,AliveReds],[],Index,_),
	index(PossMoves,Move,Index).


%%%%%% LAND GRAB SCORE/5 (Player,PossMoves,BoardState,Scores,Index)
get_land_grab_score('b',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,BestScore) :-
	alter_board(HPossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[CCNewAliveBlues,CCNewAliveReds]), 
 	length(CCNewAliveReds,RL),
	length(CCNewAliveBlues,BL),
	ThisScore is BL - RL,
	append(Scores,[ThisScore],NewScores),
	get_land_grab_score('b',TailPossMove,[AliveBlues,AliveReds],NewScores,Index,BestScore).

get_land_grab_score('b',[PossMove],[AliveBlues,AliveReds],Scores,Index,BestScore) :-
	alter_board(PossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[CCNewAliveBlues,CCNewAliveReds]),
 	length(CCNewAliveReds,RL),
	length(CCNewAliveBlues,BL),
	ThisScore is BL - RL,
	append(Scores,[ThisScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('LG: List of Scores: ~w ~n', [NewScores]),
	%format('LG: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).


get_land_grab_score('r',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,BestScore) :-
	alter_board(HPossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,CCNewAliveReds]), 
 	length(CCNewAliveBlues,BL),
	length(CCNewAliveReds,RL),
	ThisScore is RL - BL,
	append(Scores,[ThisScore],NewScores),
	get_land_grab_score('r',TailPossMove,[AliveBlues,AliveReds],NewScores,Index,BestScore).

get_land_grab_score('r',[PossMove],[AliveBlues,AliveReds],Scores,Index,BestScore) :-
	alter_board(PossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,CCNewAliveReds]),
 	length(CCNewAliveBlues,BL),
	length(CCNewAliveReds,RL),
	ThisScore is RL - BL,
	append(Scores,[ThisScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('LG: List of Scores: ~w ~n', [NewScores]),
	%format('LG: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).



%%%%%% MINIMAX STRATEGY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minimax('b',[AliveBlues,AliveReds],[NewAliveBlues,AliveReds], Move):-
	minimax_move('b',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveBlues,NewAliveBlues).

minimax('r',[AliveBlues,AliveReds],[AliveBlues,NewAliveReds], Move):-
	minimax_move('r',[AliveBlues,AliveReds],Move),
	alter_board(Move,AliveReds,NewAliveReds).


minimax_move('b',[AliveBlues,AliveReds], Move) :-
	poss_moves_blue([AliveBlues,AliveReds],PossMoves),
	get_minimax_score('b',PossMoves,[AliveBlues,AliveReds],[],Index,0),
	index(PossMoves,Move,Index).

minimax_move('r',[AliveBlues,AliveReds], Move) :-
	poss_moves_red([AliveBlues,AliveReds],PossMoves),
	get_minimax_score('r',PossMoves,[AliveBlues,AliveReds],[],Index,0),
	index(PossMoves,Move,Index).


%%%%%% MINIMAX SCORE/6 (Player,PossMoves,BoardState,Scores,Index,FinalMoveCheck)


% first check if game is over after the CC (final move of game)
get_minimax_score('b',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,0) :-
	%If RL = 0, Index is current move, return!!
	alter_board(HPossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[_,CCNewAliveReds]),
 	length(CCNewAliveReds,RL),
	(  RL=0 ->
    		%format('Finishing move is: ~w ~n', [HPossMove]),
		length(Scores,Index),!
	;  RL\=0 ->
		get_minimax_score('b',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,1)).

get_minimax_score('b',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,1) :-
	alter_board(HPossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[CCNewAliveBlues,CCNewAliveReds]),
 	length(CCNewAliveReds,RL),
	length(CCNewAliveBlues,BL),
	MyScore is BL - RL,
	poss_moves_red([CCNewAliveBlues,CCNewAliveReds],RedPossMoves),
	get_land_grab_score('r',RedPossMoves,[CCNewAliveBlues,CCNewAliveReds],[],_,BestRedScore),
	MiniMaxScore is MyScore - BestRedScore,
	append(Scores,[MiniMaxScore],NewScores),
	get_minimax_score('b',TailPossMove,[AliveBlues,AliveReds],NewScores,Index,0).

get_minimax_score('b',[PossMove],[AliveBlues,AliveReds],Scores,Index,1) :-
	alter_board(PossMove,AliveBlues,NewAliveBlues),
 	next_generation([NewAliveBlues,AliveReds],[CCNewAliveBlues,CCNewAliveReds]),
 	length(CCNewAliveReds,RL),
	length(CCNewAliveBlues,BL),
	MyScore is BL - RL,
	poss_moves_red([CCNewAliveBlues,CCNewAliveReds],RedPossMoves),
	get_land_grab_score('r',RedPossMoves,[CCNewAliveBlues,CCNewAliveReds],[],_,BestRedScore),
	MiniMaxScore is MyScore - BestRedScore,
	append(Scores,[MiniMaxScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('MM: List of Scores: ~w ~n', [NewScores]),
	%format('MM: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).



% first check if game is over after the CC (final move of game)
get_minimax_score('r',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,0) :-
	%If BL = 0, Index is current move, return!!
	alter_board(HPossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,_]),
 	length(CCNewAliveBlues,BL),
	(  BL=0 ->
    		%format('Finishing move is: ~w ~n', [HPossMove]),
		length(Scores,Index),!
	;  BL\=0 ->
		get_minimax_score('r',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,1)).

get_minimax_score('r',[HPossMove|TailPossMove],[AliveBlues,AliveReds],Scores,Index,1) :-
	alter_board(HPossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,CCNewAliveReds]), 
 	length(CCNewAliveBlues,BL),
	length(CCNewAliveReds,RL),
	MyScore is RL - BL,
	poss_moves_blue([CCNewAliveBlues,CCNewAliveReds],BluePossMoves),
	get_land_grab_score('b',BluePossMoves,[CCNewAliveBlues,CCNewAliveReds],[],_,BestBlueScore),
	MiniMaxScore is MyScore - BestBlueScore,
	append(Scores,[MiniMaxScore],NewScores),
	get_minimax_score('r',TailPossMove,[AliveBlues,AliveReds],NewScores,Index,0).

get_minimax_score('r',[PossMove],[AliveBlues,AliveReds],Scores,Index,1) :-
	alter_board(PossMove,AliveReds,NewAliveReds),
 	next_generation([AliveBlues,NewAliveReds],[CCNewAliveBlues,CCNewAliveReds]),
 	length(CCNewAliveBlues,BL),
	length(CCNewAliveReds,RL),
	MyScore is RL - BL,
	poss_moves_blue([CCNewAliveBlues,CCNewAliveReds],BluePossMoves),
	get_land_grab_score('b',BluePossMoves,[CCNewAliveBlues,CCNewAliveReds],[],_,BestBlueScore),
	MiniMaxScore is MyScore - BestBlueScore,
	append(Scores,[MiniMaxScore],NewScores),
	max_e_list(NewScores,BestScore),
	%format('MM: List of Scores: ~w ~n', [NewScores]),
	%format('MM: Best Score is : ~w ~n', [BestScore]),
	index(NewScores,BestScore,Index).






