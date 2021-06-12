-module(records).
-export([first_robot/0]).

-record(robot, {
	name,
	type=industrial,
	hobbies,
	details=[]
}).

first_robot() -> #robot{name="Mechatron", type=handmade, details=["Moved by a small man inside"]}.
