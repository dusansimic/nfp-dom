-module(sesjedan).
-author("Dušan Simić").
-export([sekugod/0, deljivo/0, jedanmanje/0, ispravan/0, trojka/0, nadji/0, trecinacetvrti/0, prazna/1, jedan/1]).

sekugod() -> 365 * 24 * 60 * 60.

deljivo(A,B) -> (A rem B) =:= 0.

%% Evidentno jeste
deljivo() -> deljivo(532253373,23).

%% Jeste, brojevi su "manji" od atoma.
jedanmanje() -> 1 < true.

%% Jeste ali nije prava lista. Prava lista se zavrsava sa praznom listom dakle ili se pise kao
%% [1,2] ili [1 | [2 | []] da bi bila prava.
ispravan() -> [1|2].

trojka() -> {atom, 0, [100,117,115,97,110]}.

nadji() -> element(3, {atom, 0, [100,117,115,97,110], <<"dusan">>}).

trecinacetvrti() -> math:pow(3,4).

prazna(A) -> length(A) =:= 0.

jedan(A) -> length(A) =:= 1.
