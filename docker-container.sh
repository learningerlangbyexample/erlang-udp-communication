#!/usr/bin/env escript

main([HostIpString]) ->
    io:format("~nContainer: Received host IP: ~s~n", [HostIpString]),
    {ok, HostIp} = inet:parse_address(HostIpString),
    {ok,Socket} = gen_udp:open(6667, [binary]),
    wait_for_downloading_to_start(Socket, HostIp),
    ok;

main(_) ->
    usage().

usage() ->
    io:format("usage: docker-container.sh <HostIp>~n"),
    halt(1).

wait_for_downloading_to_start(Socket, HostIp) ->
    receive
        {udp, _, _, _, BinaryMessage} ->
            case binary_to_term(BinaryMessage) of
                downloading_started ->
                    io:format("~nContainer: Download started!~n"),
                    wait_for_downloading_to_finish()
            end
    after
        1000 ->
            io:format(user, ".", []),
            send_ready_ping(Socket, HostIp),
            wait_for_downloading_to_start(Socket, HostIp)
    end.

wait_for_downloading_to_finish() ->
    receive
        {udp, _, _, _, BinaryMessage} ->
            case binary_to_term(BinaryMessage) of
                downloading_finished ->
                    io:format("Container: Download finished!~n")
            end
    end.

send_ready_ping(Socket, HostIp) ->
    MyOwnIp = get_local_ip_address(HostIp),
    gen_udp:send(Socket,
                 HostIp,
                 6666,
                 term_to_binary({releases_are_ready,
                                 {from, MyOwnIp}
                                })),
    ok.

get_local_ip_address(HostIp) ->
    {IP1, IP2, _, _} = HostIp,
    {ok, IPs} = inet:getif(),
    [LocalIp | _] = [IP || {IP, _, _} <- IPs,
                           case IP of
                               {IP1, IP2, _, _} -> true;
                               _ -> false
                           end],
    LocalIp.
