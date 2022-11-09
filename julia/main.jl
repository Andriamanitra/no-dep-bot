import Dates

include("./twitchbot.jl")


TIMESTAMP_FORMAT = Dates.DateFormat("HH:MM:SS")

function main()
    print("Channels to join: ")
    channels = split(readline(), ",")

    sock = connect()
    send(msg) = write(sock, "$msg\r\n")

    for chan in channels
        send("JOIN #$chan")
    end

    # julia does some weird stuff with signals by default so this is required
    Base.exit_on_sigint(false)

    # using a channel to do communication between the task receiving messages and
    # the task printing the messages (instead of just doing everything synchronously in
    # the same task) is a little bit silly, but I needed some way to have a task that is
    # not blocking even when there are no messages incoming
    chan = Channel()

    @async while true
        line = readline(sock)
        if isempty(line)
            put!(chan, "disconnected")
            close(chan)
        end
        msg = parsemsg(line)
        if msg isa PrivMsg
            t_stamp = Dates.format(Dates.now(), TIMESTAMP_FORMAT)
            put!(chan, "$(msg.channel) [$t_stamp] <$(msg.user)> $(msg.msg)")
        else
            put!(chan, msg)
        end
    end

    try
        while true
            # unfortunately julia seems to not process SIGINT during blocking
            # calls so we need to sleep between handling messages to make sure
            # the SIGINT can get handled properly
            if isready(chan)
                println(take!(chan))
            else
                sleep(0.001)
            end
        end
    catch exc
        if exc isa InterruptException
            println("Stopping..")
            send("QUIT")
            close(sock)
            println("Disconnected.")
            exit(0)
        else
            rethrow()
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
