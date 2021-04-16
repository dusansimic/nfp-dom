-module(useless).
%% Ovako se importuju funkcije iz drugih modula
%% Doduse to nije preporuceno jer se smanjuje citljivost koda
%% -import(io, [format/1]).
-export([add/2,hello/0,greet_and_add_two/1]).
%% Makroi funkcionisu slicno kao #define u C-u
%% -define(MACRO, value).
%% ?MACRO

add(A,B) -> A + B.

%% Pozdravi svet
%% io:format/1 je standardna funkcija za ispisivanje teksta
hello() -> io:format("Hello, world!~n").

greet_and_add_two(X) -> hello(), add(X,2).
