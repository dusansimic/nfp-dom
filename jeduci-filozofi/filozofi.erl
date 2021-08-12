-module(filozofi).
-export([init/1, stop/1]).

% Inicijalizuju se svi procesi za viljuske (kojih ima 5) i filozofe (kojih ima 5).
% ["Aristotel", "Kant", "Spinoza", "Marks", "Rasel"]
init(Imena) when length(Imena) > 1 ->
	Viljuske = napravi_viljuske(length(Imena)),
	Filozofi = napravi_filozofe(Imena, Viljuske),
	{Filozofi, [V || {_Id, V} <- Viljuske]}.

stop({Filozofi, Viljuske}) ->
	[F ! stop || F <- Filozofi],
	[V ! stop || V <- Viljuske].

% Pravljenje viljuski
napravi_viljuske(N) when N > 0 -> napravi_viljuske(N, []).

napravi_viljuske(0, V) -> lists:reverse(V);
napravi_viljuske(N, V) ->
	Viljuska = spawn(fun() -> viljuska(N, slobodna) end),
	napravi_viljuske(N-1, lists:append(V, [{N, Viljuska}])).

% Viljuska ukoliko je slobodna moze biti samo uzeta a ukoliko je zauzeta moze biti samo
% ostavljenja.
viljuska(Id, slobodna) ->
	receive
		{Od, uzmi} ->
			Od ! ok,
			viljuska(Id, zauzeta);
		stop -> ok
	end;
viljuska(Id, zauzeta) ->
	receive
		{Od, uzmi} ->
			Od ! nok,
			viljuska(Id, zauzeta);
		{Od, ostavi} ->
			Od ! ok,
			viljuska(Id, slobodna);
		stop -> ok
	end.

% Funkcija za enkapsulaciju uzimanja viljuske.
uzmi(Viljuska) ->
	Viljuska ! {self(), uzmi},
	receive
		ok -> ok;
		nok -> nok
	end.

% Funkcija za enkapsulaciju ostavljanja viljuske.
ostavi(Viljuska) ->
	Viljuska ! {self(), ostavi},
	receive
		ok -> ok
	end.

% Pravljenje filozofa i dodeljivanje viljuski
napravi_filozofe(Imena, Viljuske) when length(Imena) =:= length(Viljuske) ->
	napravi_filozofe(Imena, Viljuske, []).

napravi_filozofe([], _, F) -> F;
napravi_filozofe([Hi|Ti], [Lv,Dv|Vl], Fl) ->
	Filozof = spawn(fun() -> filozof(Hi, [Lv, Dv]) end),
	napravi_filozofe(
		Ti,
		nakraj([Lv,Dv|Vl], 1),
		lists:append(Fl, [Filozof])
	).

filozof(Ime, [{IdP, P},{IdD, D}]) when IdP > IdD -> filozof(Ime, [D, P]);
filozof(Ime, [{_, P},{_, D}]) -> filozof(Ime, [P, D]);
% Filozof na samom pocetku misli, zatim uzima prvu pa drugu viljusku jer je gladan i krece da
% jede. Kada zavrsi sa jelom ostavlja prvu pa drugu viljusku i zapocinje ponovo proces.
filozof(Ime, [Prva, Druga]) ->
	receive
		stop -> io:format("~s izlazi.~n", [Ime]), ok
	after 0 ->
		io:format("~s misli.~n", [Ime]),
		timer:sleep(rand:uniform(1000)),
		io:format("~s je gladan.~n", [Ime]),

		case uzmi(Prva) of
			nok ->
				io:format("Prva viljuska je zauzeta. ~s ide da misli.~n", [Ime]),
				filozof(Ime, [Prva, Druga]);
			ok ->
				io:format("~s je uzeo prvu viljusku.~n", [Ime])
		end,

		case uzmi(Druga) of
			nok ->
				ostavi(Prva),
				io:format("Druga viljuska je zauzeta. ~s je ostavio prvu viljusku i ide da misli.~n", [Ime]),
				filozof(Ime, [Prva, Druga]);
			ok ->
				io:format("~s je uzeo drugu viljusku.~n", [Ime])
		end,

		io:format("~s jede.~n", [Ime]),
		timer:sleep(rand:uniform(1000)),

		ostavi(Prva),
		io:format("~s je ostavio prvu viljusku.~n", [Ime]),
		ostavi(Druga),
		io:format("~s je ostavio drugu viljusku.~n", [Ime]),

		filozof(Ime, [Prva, Druga])
	end.


% Na kraj prebacuje prvi element na kraj da bi se prilikom pravljenja liste filozofa moglo doci
% do odgovarajuceg redosleda viljuski.
nakraj(L, 0) -> L;
nakraj([H|L], 1) -> nakraj(lists:append(L, [H]), 0).
