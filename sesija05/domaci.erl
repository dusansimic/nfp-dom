-module('domaci').
-export([mapa/2,precistac/2,preklop/3,sum/1,sum_tail/1,preklopni_precistac/1,sledeci/1,generisi/2,seq_filter/2,seq_map/2,prvih/2,mapa_bezdan/3,precistac_bezdan/3,prvih_deset_neparnih/0]).

%% 31.
mapa(Pred,L) -> lists:reverse(mapa(Pred,L,[])).
mapa(_,[],T) -> T;
mapa(Pred,[H|T],Tl) -> mapa(Pred,T,[Pred(H)|Tl]).

%% 32.
% domaci:mapa(fun(N) -> N*N end,[1,2,3]).

%% 33.
precistac(_,[]) -> [];
precistac(Pred,[H|T]) ->
	case Pred(H) of
		true -> [H|precistac(Pred,T)];
		_ -> precistac(Pred,T)
	end.

%% 34.

% domaci:precistac(fun(N) -> (N rem 2) =:= 0 end,[1,2,3,4,5,6]).

%% 35.
preklop(_, Acc, []) -> Acc;
preklop(Pred, Acc, [H|T]) -> preklop(Pred, Pred(Acc,H), T).

% domaci:preklop(fun(Acc,N) -> Acc+N end,0,[1,2,3]).

%% 36.
%% Preuzeto iz mog resenja domaceg iz sesije 4.
sum([]) -> 0;
sum([H|T]) -> H + sum(T).

sum_tail(L) -> sum_tail(L,0).
sum_tail([],S) -> S;
sum_tail([H|T],S) -> sum_tail(T,S+H).

%% 37.
preklopni_precistac(L) -> lists:reverse(preklop(
	fun(Acc,N) ->
		case (N rem 2) =:= 0 of
			true -> [N|Acc];
			_ -> Acc
		end
	end,
	[],
	L)).

%% 38.
% Shvatio

%% 39.

sledeci(Seq) -> fun() -> [Seq|sledeci(Seq+1)] end.

%% Generise listu uz pomoc lenje funkcije do zadatog elementa.
% Nije bas najefikasnije resnenje ali sam ga koristio samo da bih video da li mi lenja lista
% radi kako valja.
generisi(SeqFun, Fin) ->
	[Val|_] = SeqFun(),
	generisi(Val, SeqFun, Fin).

generisi(Seq, _, Fin) when Seq > Fin -> [];
generisi(Seq, _, Fin) when Seq =:= Fin -> [Seq];
generisi(Seq, SeqFun, Fin) when Seq < Fin ->
	[Val|Func] = SeqFun(),
	[NextVal|_] = Func(),
	[Val|generisi(NextVal, Func, Fin)].

%% Generise prvih N elemenata liste lenje funkcije
prvih(_, Fin) when Fin =:= 0 -> [];
prvih(SeqFun, Fin) when Fin > 0 ->
	[Val|Func] = SeqFun(),
	[Val|prvih(Func, Fin-1)].

%% Pravi lenju filter funkciju.
% Wrappuje lenju funkciju i pravi listu iskljucivo od elemenata koji zadovoljavaju predikatsku
% funkciju
seq_filter(Pred, SeqFun) ->
	[Val|Func] = SeqFun(),
	case Pred(Val) of
		true -> fun() -> [Val|seq_filter(Pred, Func)] end;
		_ -> seq_filter(Pred, Func)
	end.

%% Pravi lenju map funkciju.
% Wrappuje lenju funkciju i prvi listu od rezultata predikatske funkcije
seq_map(Pred, SeqFun) ->
	[Val|Func] = SeqFun(),
	fun() -> [Pred(Val)|seq_map(Pred,Func)] end.

%% Map za lenje liste
% U ovom resenju vraca se prvih N elemenata lenje liste koji su proterani kroz predikatsku
% funkciju.
mapa_bezdan(Pred,SeqFun,Fin) ->
	prvih(
		seq_map(Pred, SeqFun),
		Fin
	).

% domaci:mapa_bezdan(fun(N) -> N*N end, domaci:sledeci(1), 5).

%% 40.

%% Filter za lenje liste
% U ovom resenju vraca se prvih N elemenata lenje liste koji zadovoljavaju predikatsku funckiju
precistac_bezdan(Pred,SeqFun,Fin) -> 
	prvih(
		seq_filter(Pred, SeqFun),
		Fin
	).

% domaci:precistac_bezdan(fun(N) -> (N rem 2) =:= 0 end, domaci:sledeci(1), 100).

%% 41.

prvih_deset_neparnih() ->
	domaci:prvih(
		domaci:seq_map(
			fun(N) -> N*N end,
			domaci:seq_filter(
				fun(M) -> (M rem 2) =:= 1 end,
				domaci:sledeci(1)
			)
		),
		10
	).
