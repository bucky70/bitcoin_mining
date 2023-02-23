-module(client1).
-author(aalekya).
% -export([pong/0, begin_pong/0, userInput/0,findBitCoins/0]).
-export([begin_pong/0]).

% pong() ->
%     receive
%         {ping,String,Hashedstring} ->
%             io:format("the string is ~p \n", [String]),
%             io:format("the hashed string is ~p \n", [Hashedstring]),
%             pong()
%     end.
% findBitCoins()->
%     receive
%         {Ping_Id,Finished} ->
%             io:fwrite("Completed BitCoin Mining ~w~n",[Finished]);
%         {Ping_Id, BitCoin, Generate_Hash,BitCoinCodn} ->
%             io:fwrite("~w\t~ts\t~ts~n",[BitCoinCodn,BitCoin,Generate_Hash]),
%             findBitCoins()
%     end.
    
begin_pong() ->
    %register(masterpid, spawn(final, pong, [])),
    Mainpid = spawn(bitCoin_server,findBitCoins,[]),
    io:format("Server ID: ~p~n",[Mainpid]),
    rpc:call('aalekya@192.168.0.6',bitCoin_server,start,[Mainpid]),
    io:fwrite("Message sent to the worker").

% userInput() ->
%     {ok, Term} = io:read("Enter a number: "),
%     io:format("The number you entered plus one is: ~w~n", [Term + 1]).