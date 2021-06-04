-module('zadatak').
-export([levo/1,desno/1,min/1,max/1,izbroji/1,zipWithRek/2,zipWithMap/2,zipWithLC/2,unZip/1,generisi_duplo/1,lc_fold/2,nadji/2,nadji_zip/2]).

%% 2.

levo(L) -> lists:foldl(fun(N, Acc) -> Acc - N end, 0, L).
desno(L) -> lists:foldr(fun(N, Acc) -> Acc - N end, 0, L).

%% 3.

min([H|T]) -> lists:foldl(fun(N, Acc) -> case N < Acc of
		true -> N;
		_ -> Acc
	end end,
	H,
	T).

max([H|T]) -> lists:foldl(fun(N, Acc) -> case N > Acc of
		true -> N;
		_ -> Acc
	end end,
	H,
	T).

%% 4.

izbroji(L) -> lists:foldl(
	fun({milos,_}, Acc) -> Acc + 1;
	({ana,_}, Acc) -> Acc + 1;
	(_, Acc) -> Acc end,
	0,
	L
).

%% 5.

zipWithRek([],_) -> [];
zipWithRek(_,[]) -> [];
zipWithRek([H1|T1], [H2|T2]) -> [H1+H2|zipWithRek(T1,T2)].

zipWithMap(L1,L2) -> lists:map(fun({E1,E2}) -> E1+E2 end, lists:zip(L1,L2)).

zipWithLC(L1,L2) -> [E1+E2 || E1 <- L1, E2 <- L2].

%% 6.

unZip(L) -> lists:foldl(fun({E1,E2},{L1,L2}) -> {L1++[E1],L2++[E2]} end, {[],[]}, L).

%% 7.

generisi_duplo(N) -> lists:reverse(lists:foldl(fun(E, Acc) -> [E,E|Acc] end, [], lists:seq(1,N))).

%% 8.

lc_fold(Pred,L) -> lists:reverse(lists:foldl(fun(N, Acc) -> case Pred(N) of
		true -> [N*N|Acc];
		_ -> Acc
	end end,
	[],
	L)).

rajferslus([],_) -> [];
rajferslus(_,[]) -> [];
rajferslus([H1,T1],[H2,T2]) -> [{H1,H2},rajferslus(T1,T2)].

%% 9.

nadji(N,L) -> [E || {I,E} <- lists:zip(
		lists:seq(1,length(L)),L
	),
	N =:= I
].

nadji_zip(N,L) -> hd(lists:reverse(rajferslus(lists:seq(1,N),L))).