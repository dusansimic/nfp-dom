-module(propot2).
-export([init/2, stop/1]).

% Inicijalizacija svih potrebnih stvari
% Bafer se inicijalizuje na prosledjenu velicinu
% Generator sluzi za generisanje sledece vrednosti
% Inicijalizuje se isti broj proizvodjaca i potrosaca
init(Max, BrP) when Max > 0; BrP > 0 ->
	Bafer = napravi_bafer(Max),
	Generator = napravi_generator(),
	napravi_propot(BrP, Bafer, Generator).

stop({Pro, Pot}) ->
	[P ! stop || P <- Pro],
	[P ! stop || P <- Pot].

% Bafer skladisti vrednosti koje napravi neki proizvodjac da bi potrosaci mogli da ih preuzmu
napravi_bafer(Max) -> spawn(fun() -> bafer([], Max) end).
bafer(Podaci, Max) ->
	PodKol = length(Podaci),
	receive
		{Od, procitaj} ->
			if
				PodKol =:= 0 ->
					Od ! nok,
					bafer(Podaci, Max);
				PodKol > 0 ->
					[H|T] = Podaci,
					Od ! {ok, H},
					bafer(T, Max)
			end;
		{Od, zapisi, Vrednost} ->
			if
				PodKol =:= Max ->
					Od ! nok,
					bafer(Podaci, Max);
				PodKol < Max ->
					Od ! ok,
					bafer(lists:append(Podaci, [Vrednost]), Max)
			end
	end.

% Pravi se lista proizvodjaca i potrosaca
napravi_propot(N, B, G) -> napravi_propot(N, B, G, [], []).
napravi_propot(0, _, _, Pro, Pot) -> {Pro, Pot};
napravi_propot(N, B, G, Pro, Pot) ->
	napravi_propot(N-1, B, G,
		[napravi_proizvodjaca(N, B, G) | Pro],
		[napravi_potrosaca(N, B) | Pot]
	).

% Proizvodjac prvo preuzima sledecu vrednost od generatora. Generisanu vrednost zapisuje u
% bafer. Nakon toga ceka odgovor od bafera da li je vrednost zapisana (bafer nije pun) ili nije
% (bafer je pun).
napravi_proizvodjaca(Id, Bafer, Generator) -> spawn(fun() -> proizvodjac(Id, Bafer, Generator) end).
proizvodjac(Id, Bafer, Generator) ->
	receive
		stop -> ok
	after 0 ->
		Self = self(),
		Generator ! {Self, generisi},
		receive
			{generisano, SledecaVrednost} ->
				Bafer ! {Self, zapisi, SledecaVrednost}
		end,
		receive
			ok -> io:format("Proizvodjac ~w je napravio proizvod!~n", [Id]);
			nok -> io:format("Proizvodjac ~w nije napravio proizvod!~n", [Id])
		end,
		timer:sleep(rand:uniform(1000)),
		proizvodjac(Id, Bafer, Generator)
	end.

% Generator vraca sledecu vrednost na svaki zahtev za generisanje.
napravi_generator() -> spawn(fun() -> generator(1) end).
generator(N) ->
	receive
		{Od, generisi} ->
			Od ! {generisano, N},
			generator(N+1)
	end.

% Potrosac cita vrednosti iz bafera. Ukoliko dobije ok odgovor, bafer nije prazan i vrednost je
% procitana a ukoliko dobije nok odgovor, bafer je prazan i potrosac nema sta da trosi.
napravi_potrosaca(Id, Bafer) -> spawn(fun() -> potrosac(Id, Bafer) end).
potrosac(Id, Bafer) ->
	receive
		stop -> ok
	after 0 ->
		timer:sleep(rand:uniform(1000)),
		Bafer ! {self(), procitaj},
		receive
			{ok, Vrednost} -> io:format("Proizvod ~w je potrosen od strane potrosaca ~w!~n", [Vrednost, Id]);
			nok -> io:format("Nema dostupnih proizvoda za potrosaca ~w!~n", [Id])
		end,
		potrosac(Id, Bafer)
	end.
