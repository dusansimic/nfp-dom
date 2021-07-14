-module(echo).
-export([go/0, loop/0]).

go() ->
	io:format("Pid: ~w~n", [self()]),
	register(loop, spawn(?MODULE, loop, [])),
	% _ = spawn(fun() -> io:format("Pid2: ~w~n", [self()]) end),
	loop ! {self(), echo},
	receive
		echo -> io:format("Echoed~n")
	end.
	% loop ! stop.

loop() ->
	io:format("Pid: ~w~n", [self()]),
	receive
		{From, Msg} ->
			From ! Msg,
			loop();
		stop ->
			ok
	end.
