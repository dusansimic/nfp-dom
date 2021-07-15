-module(filozofi).
-export([init/0]).

init() ->
	Viljuske = napravi_viljuske(5),
	Filozofi = napravi_filozofe(
		["Aristotel", "Kant", "Spinoza", "Marks", "Rasel"],
		Viljuske
	),
	[spawn(F) || F <- Filozofi],
	ok.

napravi_viljuske(N) when N > 0 -> napravi_viljuske(N, []).

napravi_viljuske(0, V) -> lists:reverse(V);
napravi_viljuske(N, V) ->
	Viljuska = spawn(fun() -> viljuska(N, slobodna) end),
	napravi_viljuske(N-1, lists:append(V, [Viljuska])).

viljuska(Id, slobodna) ->
	receive
		{Od, uzmi} ->
			Od ! ok,
			viljuska(Id, zauzeta)
	end;
viljuska(Id, zauzeta) ->
	receive
		{Od, ostavi} ->
			Od ! ok,
			viljuska(Id, slobodna)
	end.

uzmi(Viljuska) ->
	Viljuska ! {self(), uzmi},
	receive
		ok -> ok
	end.

ostavi(Viljuska) ->
	Viljuska ! {self(), ostavi},
	receive
		ok -> ok
	end.

napravi_filozofe(Imena, Viljuske) when length(Imena) =:= length(Viljuske) ->
	napravi_filozofe(Imena, Viljuske, []).

napravi_filozofe([], _, F) -> F;
napravi_filozofe([Hi|Ti], [Lv,Dv|Vl], Fl) ->
	Filozof = fun() -> filozof(Hi, [Lv, Dv]) end,
	napravi_filozofe(
		Ti,
		nakraj([Lv,Dv|Vl], 1),
		lists:append(Fl, [Filozof])
	).

filozof(Ime, [Leva, Desna]) ->
	io:format("~s misli.~n", [Ime]),
	timer:sleep(rand:uniform(1000)),
	io:format("~s je gladan.~n", [Ime]),

	uzmi(Leva),
	uzmi(Desna),

	io:format("~s jede.~n", [Ime]),
	timer:sleep(rand:uniform(1000)),

	ostavi(Leva),
	ostavi(Desna),

	filozof(Ime, [Leva, Desna]).

nakraj(L, 0) -> L;
nakraj([H|L], 1) -> nakraj(lists:append(L, [H]), 0).
