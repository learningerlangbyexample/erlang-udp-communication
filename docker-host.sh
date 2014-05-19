#!/usr/bin/env escript
main([DockerName, RemotePath, LocalPath]) ->
    {ok,Socket} = gen_udp:open(6666, [binary]),
    wait_for_releases_to_be_ready(Socket,
                                  DockerName,
                                  RemotePath,
                                  LocalPath),
    ok;

main(_) ->
    usage().

usage() ->
    io:format(
      "usage: docker-container.sh " ++
          "<Docker container name> " ++
          "<Remote path> " ++
          "<Local path>~n"),
    halt(1).

wait_for_releases_to_be_ready(Socket,
                              DockerName,
                              RemotePath,
                              LocalPath) ->

    receive
        {udp, _, _, _, BinaryMessage} ->
            case binary_to_term(BinaryMessage) of
                {releases_are_ready, {from, ContainerIp}} ->
                    io:format("Host: Received container IP: ~p~n", [ContainerIp]),
                    io:format("Host: Started downloading!~n"),
                    download_releases(Socket,
                                      ContainerIp,
                                      DockerName,
                                      RemotePath,
                                      LocalPath)
            end
    end.

download_releases(Socket,
                  ContainerIp,
                  DockerName,
                  RemotePath,
                  LocalPath) ->

    gen_udp:send(Socket,
                 ContainerIp,
                 6667,
                 term_to_binary(downloading_started)),

    Command = "docker cp " ++
        DockerName ++ ":" ++
        RemotePath ++ " " ++
        LocalPath,
    os:cmd(Command),

    unpack_tar_file(Socket, ContainerIp, LocalPath).

unpack_tar_file(Socket, ContainerIp, LocalPath) ->
    Command = "cd " ++ LocalPath ++
        " && tar xf *.tar.gz" ++
        " && ls -la "++ LocalPath ++ "/releases",
    os:cmd(Command),

    close_docker_container(Socket, ContainerIp).

close_docker_container(Socket, ContainerIp) ->
    gen_udp:send(Socket,
                 ContainerIp,
                 6667,
                 term_to_binary(downloading_finished)),
    io:format("Host: Finished downloading!~n"),
    ok.
