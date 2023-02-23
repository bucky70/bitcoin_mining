-module(bitCoin_worker).
-import(lists,[sum/1]). 
-export([bitCoinOutput/5, generateString/2 ]).

generateString(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(rand:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).

bitCoinOutput(Pid, K1, FirstItr, LastItr,BitCoinCodn) ->
    if
    
      FirstItr < LastItr ->
         %io:fwrite("Core ~w Iteration ~w~n",[BitCoinCodn,FirstItr]),
        Num_List = lists:seq(48,57),
        Lowercase_alph_list = lists:seq($a,$z),
        Uppercase_alph_list = lists:seq($A,$Z),
        All_Seq = Lowercase_alph_list++Num_List++Uppercase_alph_list,
        %io:fwrite("~ts~n",[All_Seq]),
        Var = generateString(10,All_Seq),
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
               bitCoinOutput(Pid, K1, FirstItr+1, LastItr,BitCoinCodn);
            true ->
               bitCoinOutput(Pid,K1, FirstItr+1, LastItr,BitCoinCodn)

         end;
      true ->
        Pid ! {self(),BitCoinCodn}
        %bitCoinOutput(Pid,K1, FirstItr+1, LastItr,BitCoinCodn)
        %io:fwrite("~n")
   end.
