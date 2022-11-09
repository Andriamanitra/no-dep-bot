import Test
import Dates

include("./twitchbot.jl")


TIMESTAMP_FORMAT = Dates.DateFormat("HH:MM:SS")

function showmsg(msg::Message)
    println("'$(msg.raw)'")
    println("    command='$(msg.command)'")
    println("    prefix='$(msg.prefix)'")
    println("    params=$(msg.params)")
    println("    tags:")
    for key in sort(collect(keys(msg.tags)))
        val = msg.tags[key]
        println("        $key: '$val'")
    end
    
end

function showmsg(msg::PrivMsg)
    timestamp = Dates.DateTime("2006-01-02T15:04:05")
    ts = Dates.format(timestamp, TIMESTAMP_FORMAT)
    println("$(rpad(msg.channel, 10)) [$ts] <$(msg.user)> $(msg.msg)")
end

Test.@test begin
    for line in eachline(ARGS[1])
        line |> parsemsg |> showmsg
    end
    true
end
