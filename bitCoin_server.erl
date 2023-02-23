-module(bitCoin_server). 
-import(lists,[sum/1]). 
-export([createProcess/7, findBitCoins/0,start/0,start/1,generate_random_string/0,bitCoinOutput/6]).

findBitCoins()->
    receive
        {Finished,T} ->
            io:format("Done with the Bitcoin Mining ~w~n",[T]),
            findBitCoins();
        {Ping_Id, BitCoin, Generate_Hash,BitCoinCodn} ->
            io:fwrite("~w\t~ts\t~ts~n",[BitCoinCodn,BitCoin,Generate_Hash]),
            findBitCoins()
    end.

%to run on remote systemm
start() ->
    io:fwrite("Begin call to server .~n"),
    statistics(runtime),
    statistics(wall_clock),
    Server = spawn(bitCoin_server, findBitCoins,[]),
    TotalCores=erlang:system_info(logical_processors_available),
    createProcess(Server, 3, 0, 100000000, TotalCores, 0,0).
   %bitCoinOutput(Server, 3, 0, 100000000,TotalCores,0).

%to run on own system
start(Server)->
    TotalCores=erlang:system_info(logical_processors_available),
    createProcess(Server, 3, 0, 1000000000, TotalCores, 0,0).


createProcess(Pong_id,Leading_zeros_Count,FirstItr,LastItr,TotalCores,SpawnCounter,Count) ->
    if(SpawnCounter < TotalCores)->
        %io:format("Completed ~w~n",[SpawnCounter]),
        spawn(bitCoin_worker,bitCoinOutput,[Pong_id, Leading_zeros_Count, FirstItr, LastItr,SpawnCounter]),
        %createProcess(Pong_id, Leading_zeros_Count, LastItr, LastItr+1000000,TotalCores,SpawnCounter+1);  
         bitCoinOutput(Pong_id, 3, 0, 100000000,SpawnCounter,0),
        createProcess(Pong_id, Leading_zeros_Count, FirstItr, LastItr,TotalCores,SpawnCounter+1,Count+1);
        
        
    true ->
        io:format("BitCoin mining finished~n")
end.

generate_random_string()->
    Z=base64:encode(crypto:strong_rand_bytes(4)),
    A=string:concat("padamatisaikumar",binary_to_list(Z)),
    A.

bitCoinOutput(Pid, K1, FirstItr, LastItr,BitCoinCodn,Count) ->
    {_,T1} = statistics(runtime),
    {_,T2} = statistics(wall_clock),
    U1=T1,
    U2=T2,
    if   
      FirstItr < LastItr ->
         %io:fwrite("Core ~w Iteration ~w~n",[BitCoinCodn,FirstItr]),
        Num_List = lists:seq(48,57),
        Lowercase_alph_list = lists:seq($a,$z),
        Uppercase_alph_list = lists:seq($A,$Z),
        All_Seq = Lowercase_alph_list++Num_List++Uppercase_alph_list,
        %io:fwrite("~ts~n",[All_Seq]),
        Var = generate_random_string(),
        Final_string = "achintala;" ++ Var,    
         Generate_Hasd = binary:encode_hex(crypto:hash(sha256, Final_string)),
         {Zeros, _} = split_binary(Generate_Hasd,K1),
         ZerosList = bitstring_to_list(Zeros),
         Sum = sum(ZerosList),
         Comp = K1 * 48,
         if
            Sum == Comp ->
                Pid ! {self(),Final_string,Generate_Hasd,BitCoinCodn},
                %io:fwrite("Core ~w Iteration ~w ~ts\t~ts~n",[BitCoinCodn,FirstItr,Final_string,Generate_Hasd]),
                %------------------
            if(Count==50)->
                CPU_time = U1/ 1000,
                Run_time = U2 / 1000,
                T3 = CPU_time / Run_time,
                io:format("CPU time: ~p seconds\n", [CPU_time]),
                io:format("Real time: ~p seconds\n", [Run_time]),
                io:format("Ratio is ~p \n", [T3]);
                %createProcess(Server, 3, 0, 100000000, TotalCores, 0,count+1);
            true->
             bitCoinOutput(Pid, K1, FirstItr+1, LastItr,BitCoinCodn,Count+1)
            end;
            %-----------------------
              
            true ->
               bitCoinOutput(Pid,K1, FirstItr+1, LastItr,BitCoinCodn,Count+1)

         end;
      true ->
        Pid ! {self(),BitCoinCodn}
        %bitCoinOutput(Pid,K1, FirstItr+1, LastItr,BitCoinCodn)
        %io:fwrite("~n")
   end.


    


