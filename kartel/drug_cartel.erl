-module(drug_cartel).
-export([warehouse/0]).

guard(Traffickers, Password) ->
	receive
		{let_in, Who} ->
			Who ! whats_the_password,
			guard(Traffickers, Password);
		{password, Password, Who} ->
			Who ! come_in,
			guard([Who|Traffickers], Password);
		{password, _IncorrectPassword, Who} ->
			Who ! go_away,
			guard(Traffickers, Password);
		im_a_cop ->
			[T ! cops_are_here || T <- Traffickers]
	end.

bad_guy(Password) ->
	guard ! {let_in, self()},
	receive
		whats_the_password -> guard ! {password, Password, self()}
	end,
	receive
		go_away -> io:format("Guard didn't let me in.~n");
		come_in ->
			receive
				cops_are_here -> io:format("I'm outta here!~n")
			end
	end.

fbi() ->
	guard ! {let_in, self()},
	receive
		whats_the_password -> guard ! im_a_cop
	end.

warehouse() ->
	IncorrectPassword = "margherita",
	Password = "quattro stagioni",

	register(guard, spawn(fun() -> guard([], Password) end)),

	spawn(fun() -> bad_guy(Password) end),
	spawn(fun() -> bad_guy(IncorrectPassword) end),
	spawn(fun() -> bad_guy(Password) end),
	spawn(fun() -> bad_guy(Password) end),
	spawn(fun() -> bad_guy(IncorrectPassword) end),
	spawn(fun() -> bad_guy(IncorrectPassword) end),
	spawn(fun() -> bad_guy(Password) end),

	timer:sleep(1000),

	spawn(fun() -> fbi() end),
	ok.
