-module(propot).
-export([init/1, menadzer/2, proizvodjac/1, potrosac/1]).

% Funkcija inicijalizuje niti za proizvodjaca, potrosaca i menadzera. Menadzeru prosledjuje
% maksimalan broj podataka.
init(L) ->
	Menadzer = spawn(?MODULE, menadzer, [0, L]),
	spawn(?MODULE, proizvodjac, [Menadzer]),
	spawn(?MODULE, potrosac, [Menadzer]),
	ok.

% Kontrolisu se proizvodjaci i potrosaci tako da se ne moze proizvesti vise stvari ukoliko je
% buffer pun i ne mogu se trositi stvari ukoliko je buffer prazan.
menadzer(0, L) ->
	% io:format("0 ~w~n", [L]),
	receive
		{Od, proizvedi} ->
			Od ! ok,
			menadzer(1, L);
		{Od, potrosi} ->
			Od ! nok,
			menadzer(0, L)
	end;
menadzer(L, L) ->
	% io:format("~w ~w~n", [L, L]),
	receive
		{Od, proizvedi} ->
			Od ! nok,
			menadzer(L, L);
		{Od, potrosi} ->
			Od ! ok,
			menadzer(L - 1, L)
	end;
menadzer(K, L) ->
	% io:format("~w ~w~n", [K, L]),
	receive
		{Od, proizvedi} ->
			Od ! ok,
			menadzer(K + 1, L);
		{Od, potrosi} ->
			Od ! ok,
			menadzer(K - 1, L)
	end.

% Proizvodjac salje poruku menadzeru za svaku proizvedenu stvar i dobija ok ili nok odgovor
% ukoliko u zamisljenom baferu ima ili nema mesta.
proizvodjac(Menadzer) ->
	Menadzer ! {self(), proizvedi},
	receive
		ok ->
			io:format("Proizvod je proizveden!~n");
		nok ->
			io:format("Proizvod nije proizveden!~n")
	end,
	timer:sleep(rand:uniform(1000)),
	proizvodjac(Menadzer).

% Potrosac salje poruku menadzeru kada zeli da trosi stvari i dobija ok ili nok odgovor ukoliko
% u baferu ima ili nema stvari.
potrosac(Menadzer) ->
	Menadzer ! {self(), potrosi},
	receive
		ok ->
			io:format("Proizvod je potrosen!~n");
		nok ->
			io:format("Proizvod nije potrosen!~n")
	end,
	timer:sleep(rand:uniform(1000)),
	potrosac(Menadzer).
