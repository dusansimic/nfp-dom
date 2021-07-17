-module(propot2).
-export([init/0, napravi_bafer/1, bafer/2, proizvodjac/3, generator/1, potrosac/2]).

% Inicijalizacija svih potrebnih stvari
% Bafer se inicijalizuje na velicinu 10
% Generator sluzi za generisanje sledece vrednosti
% Inicijalizuje se 5 proizvodjaca i 5 potrosaca
init() ->
	Bafer = napravi_bafer(10),
	Generator = napravi_generator(),
	napravi_proizvodjace(5, Bafer, Generator),
	napravi_potrosace(5, Bafer),
	ok.

% Bafer skladisti vrednosti koje napravi neki proizvodjac da bi potrosaci mogli da ih preuzmu
napravi_bafer(Max) -> spawn(?MODULE, bafer, [[], Max]).
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

% Pravi se lista proizvodjaca
napravi_proizvodjace(N, B, G) -> napravi_proizvodjace(N, B, G, []).
napravi_proizvodjace(0, _, _, P) -> P;
napravi_proizvodjace(N, B, G, P) ->
	napravi_proizvodjace(N-1, B, G, [napravi_proizvodjaca(N, B, G)|P]).

% Proizvodjac prvo preuzima sledecu vrednost od generatora. Generisanu vrednost zapisuje u
% bafer. Nakon toga ceka odgovor od bafera da li je vrednost zapisana (bafer nije pun) ili nije
% (bafer je pun).
napravi_proizvodjaca(Id, Bafer, Generator) -> spawn(?MODULE, proizvodjac, [Id, Bafer, Generator]).
proizvodjac(Id, Bafer, Generator) ->
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
	proizvodjac(Id, Bafer, Generator).

% Generator vraca sledecu vrednost na svaki zahtev za generisanje.
napravi_generator() -> spawn(?MODULE, generator, [1]).
generator(N) ->
	receive
		{Od, generisi} ->
			Od ! {generisano, N},
			generator(N+1)
	end.

% Pravi se lista potrosaca
napravi_potrosace(N, B) -> napravi_potrosace(N, B, []).
napravi_potrosace(0, _, P) -> P;
napravi_potrosace(N, B, P) ->
	napravi_potrosace(N-1, B, [napravi_potrosaca(N, B)|P]).

% Potrosac cita vrednosti iz bafera. Ukoliko dobije ok odgovor, bafer nije prazan i vrednost je
% procitana a ukoliko dobije nok odgovor, bafer je prazan i potrosac nema sta da trosi.
napravi_potrosaca(Id, Bafer) -> spawn(?MODULE, potrosac, [Id, Bafer]).
potrosac(Id, Bafer) ->
	timer:sleep(rand:uniform(1000)),
	Bafer ! {self(), procitaj},
	receive
		{ok, Vrednost} -> io:format("Proizvod ~w je potrosen od strane potrosaca ~w!~n", [Vrednost, Id]);
		nok -> io:format("Nema dostupnih proizvoda za potrosaca ~w!~n", [Id])
	end,
	potrosac(Id, Bafer).
