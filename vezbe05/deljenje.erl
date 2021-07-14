-module(deljenje).
-export([go/2,divide/0]).

go(A, B) ->
	process_flag(trap_exit, true),
	io:format("Calc: ~w / ~w~n", [A, B]),
	io:format("Pid: ~w~n", [self()]),
	Pid = spawn_link(?MODULE, divide, []),
	io:format("Pid: ~w~n", [Pid]),
	Pid ! {self(), A, B},
	receive
		{'EXIT', _, Reason} when Reason /= normal ->
			go(A, B+1);
		{Res} ->
			io:format("Res: ~w~n", [Res])
	end,
	Pid ! stop.

divide() ->
	receive
		{Pid, A, B} -> Pid ! {A/B};
		stop -> ok
	end.
