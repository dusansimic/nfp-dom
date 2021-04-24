-module(domaci).
-author("Dušan Simić").
-export([duzmatching/1, duzguard/1, duzif/1, duzcase/1, suma/1, gendva/1, genn/1, alter/1, prost/1]).

duzmatching([_|[]], C) -> C + 1;
duzmatching([_|B], C) -> duzmatching(B, C+1).

duzmatching([]) -> 0;
duzmatching(A) -> duzmatching(A, 0).

duzguard(A, C) when A =:= [] -> C;
duzguard([_|B], C) -> duzguard(B, C+1).

duzguard(A) -> duzguard(A, 0).

duzif(A, C) ->
	if
		A =/= [] -> duzif(tl(A), C+1);
		A =:= [] -> C
	end.

duzif(A) -> duzif(A, 0).

duzcase(A, C) ->
	case A =:= [] of
		false -> duzcase(tl(A), C+1);
		true -> C
	end.

duzcase(A) -> duzcase(A, 0).

suma([A|B], C) when is_number(A) -> suma(B, C + A);
suma([], C) -> C.

suma(A) -> suma(A, 0).

gendva(L, 0) -> L;
gendva(L, N) -> gendva([N | [N | L]], N-1).

gendva(N) -> gendva([], N).

genn(L, 0, 0) -> L;
genn(L, 0, N) -> genn(L, N-1, N-1);
genn(L, C, N) -> genn([N | L], C-1, N).

genn(N) -> genn([], N, N).

alter(L, _, 0) -> L;
alter(L, true, N) -> alter([true | L], false, N-1);
alter(L, false, N) -> alter([false | L], true, N-1).

alter(N) -> alter([], true, N).

prost(N, N) -> true;
prost(C, N) when N rem C =:= 0 -> false;
prost(C, N) -> prost(C+1, N).

prost(N) when N > 1 -> prost(2, N);
prost(_) -> true.
