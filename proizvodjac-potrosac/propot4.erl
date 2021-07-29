-module(propot4).
-export([init/3, stop/1]).

init(Buf, Prods, Cons) ->
	Generator = napravi_generator(),
	Producers = napravi_producere(Prods, Generator),
	Buffer = napravi_buffer(Buf, Producers),
	Consumers = napravi_consumere(Cons, Buffer),
	{Generator, Producers, Consumers, Buffer}.

stop({Generator, Producers, Consumers, Buffer}) ->
	Generator ! stop,
	Buffer ! stop,
	[P ! stop || P <- Producers],
	[C ! stop || C <- Consumers],
	ok.

next_send([H|T], M) ->
	H ! M,
	nakraj([H|T]).

nakraj([H|T]) -> lists:append(T, [H]).

napravi_buffer(Max, Pro) -> spawn(fun() -> buffer(Max, Pro, [], 0) end).

buffer_status(Size) -> io:format("Current buffer size: ~w~n", [Size]).

buffer(Max, Pro, [Vh|Vt], Size) when Size =:= Max ->
	buffer_status(Size),
	receive
		stop -> ok;
		{Consumer, ready} ->
			Consumer ! {consume, Vh},
			buffer(Max, Pro, Vt, Size-1)
	end;
buffer(Max, Pro, [Vh|Vt] = V, Size) when Size > 0; Size < Max ->
	buffer_status(Size),
	NewPro = next_send(Pro, {self(), request}),
	receive
		stop -> ok;
		{produced, Val} ->
			buffer(Max, NewPro, lists:append(V, [Val]), Size+1);
		{Consumer, ready} ->
			Consumer ! {consume, Vh},
			buffer(Max, NewPro, Vt, Size-1)
	end;
buffer(Max, Pro, V, Size) when Size =:= 0 ->
	buffer_status(Size),
	NewPro = next_send(Pro, {self(), request}),
	receive
		stop -> ok;
		{produced, Val} ->
			buffer(Max, NewPro, lists:append(V, [Val]), Size+1)
	end.

napravi_producere(N, Gen) -> napravi_producere(N, Gen, []).
napravi_producere(0, _, Prods) -> Prods;
napravi_producere(N, Gen, Prods) ->
	napravi_producere(N-1, Gen, [napravi_producera(Gen) | Prods]).

napravi_producera(Generator) -> spawn(fun() -> producer(Generator) end).

producer(Generator) ->
	timer:sleep(rand:uniform(1000)),
	Self = self(),
	io:format("Producer ~w waiting for request.~n", [Self]),
	receive
		stop -> ok;
		{Buf, request} ->
			io:format("Producer ~w producing data.~n", [Self]),
			Generator ! {Self, generate},
			receive {generated, Val} -> Buf ! {produced, Val} end,
			producer(Generator)
	end.

napravi_consumere(N, B) -> napravi_consumere(N, B, []).
napravi_consumere(0, _, Cons) -> Cons;
napravi_consumere(N, B, Cons) ->
	napravi_consumere(N-1, B, [napravi_consumera(B) | Cons]).

napravi_consumera(B) -> spawn(fun() -> consumer(B) end).

consumer(Buf) ->
	timer:sleep(rand:uniform(1000)),
	Self = self(),
	Buf ! {Self, ready},
	io:format("Consumer ~w ready for consumption.~n", [Self]),
	receive
		stop -> ok;
		{consume, Val} ->
			io:format("Consumer ~w consumed ~w.~n", [Self, Val]),
			consumer(Buf)
	end.

napravi_generator() -> spawn(fun() -> generator(1) end).

generator(N) ->
	receive
		stop -> ok;
		{Producer, generate} ->
			Producer ! {generated, N},
			generator(N+1)
	end.
