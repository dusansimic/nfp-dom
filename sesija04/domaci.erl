-module('domaci').
-export([
	duz/1,
	duz_tail/1,
	fact/1,
	fact_tail/1,
	sum/1,
	sum_tail/1,
	koliko/1,
	jednake_simple/2,
	nti/2,
	minimalni/1,
	izbaci/2,
	izbaci_sve/2,
	umanji/3,
	nadji/2,
	nadredjeni/2,
	podskup/2,
	jednaki/2,
	unija/2
]).

%% 16.
%% Ne mogu.

%% 17.
duz([]) -> 0;
duz([_|T]) -> 1 + duz(T).

duz_tail(L) -> duz_tail(L,0).
duz_tail([],A) -> A;
duz_tail([_|T],A) -> duz_tail(T,A+1).

fact(0) -> 1;
fact(N) -> N*fact(N-1).

fact_tail(N) -> fact_tail(N,1).
fact_tail(0,N) -> N;
fact_tail(N,Na) -> fact_tail(N-1,N*Na).

sum([]) -> 0;
sum([H|T]) -> H + sum(T).

sum_tail(L) -> sum_tail(L,0).
sum_tail([],S) -> S;
sum_tail([H|T],S) -> sum_tail(T,S+H).

%% 18.
%% Resenje zadatka 30.

%% 19.
koliko([]) -> 0;
koliko([H|T]) when is_list(H) -> 1 + koliko(T);
koliko([_|T]) -> koliko(T).

%% 20.
jednake_simple(A,B) -> A =:= B.

%% 21.
nti([],_) -> [];
nti([H|_],0) -> H;
nti([_|T],N) -> nti(T,N-1).

%% 22.
minimalni([]) -> nil;
minimalni([H|T]) -> minimalni(T,H).

minimalni([],Min) -> Min;
minimalni([H|T],Min) when H < Min -> minimalni(T,H);
minimalni([_|T],Min) -> minimalni(T,Min).

%% 23.
izbaci([],_) -> [];
izbaci([X|T],X) -> T;
izbaci([H|T],X) -> [H|izbaci(T,X)].

%% 24.
izbaci_sve([],_) -> [];
izbaci_sve([X|T],X) -> izbaci_sve(T,X);
izbaci_sve([H|T],X) -> [H|izbaci_sve(T,X)].

%% 25.
umanji([],_,_) -> [];
umanji([X|T],X,Y) -> [X-Y|umanji(T,X,Y)];
umanji([H|T],X,Y) -> [H|umanji(T,X,Y)].

%% 26.
nadji([],_) -> false;
nadji([X,_,_],X) -> true;
nadji([_,L,D],X) -> nadji(L,X) or nadji(D,X).

%% 27.
nadredjeni([],_) -> nil;
nadredjeni(L,X) -> nadredjeni_cistije(L,X,nil).

%% Ovo je na manje uredan nacin odradjeno nego ono uredno resenje
% nadredjeni([],_,_) -> nil;
% nadredjeni([X,_,_],X,N) -> N;
% nadredjeni([N,L,D],X,_) ->
% 	case nadredjeni(L,X,N) of
% 		nil -> case nadredjeni(D,X,N) of
% 			nil -> nil;
% 			Y -> Y
% 		end;
% 		Y -> Y
% 	end.

nadredjeni_cistije([],_,_) -> [];
nadredjeni_cistije([X,_,_],X,N) -> [N];
nadredjeni_cistije([V,L,D],X,_) -> nadredjeni_cistije(L,X,V) ++ nadredjeni_cistije(D,X,V).

%% 28.
podskup([],_) -> true;
podskup([H|T], S) -> podskup_contains(H, S) andalso podskup(T, S).

podskup_contains(_,[]) -> false;
podskup_contains(E,[H|T]) -> (E =:= H) orelse podskup_contains(E, T).

%% 29.
jednaki(A,B) -> podskup(A,B) andalso podskup(B,A).

%% 30.
unija([],B) -> B;
% da ne presipa iz jednog u drugi bez potrebe
unija(A,[]) -> A;
unija([H|T],B) ->
	case podskup_contains(H,B) of
		false -> unija(T, [H|B]);
		_ -> unija(T,B)
	end.
