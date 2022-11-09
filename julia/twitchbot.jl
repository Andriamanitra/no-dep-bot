import Sockets


struct Message
    raw::String
    prefix::String
    command::String
    params::Vector{String}
    tags::Dict{String, String}
end


struct PrivMsg
    raw::String
    channel::String
    user::String
    msg::String
    tags::Dict{String, String}
end


function parsetags(rawmsg::AbstractString)
    tags = Dict()
    if startswith(rawmsg, '@')
        tags_str, rawmsg = split(rawmsg, ' '; limit=2)
        for tag in split(tags_str[2:end], ';')
            name, value = split(tag, '='; limit=2)
            tags[name] = value
        end
    end
    return tags, rawmsg
end


function parsemsg(rawmsg::String)
    tags, rawmsg = parsetags(rstrip(rawmsg))
    if startswith(rawmsg, ':')
        space_index = findfirst(' ', rawmsg)
        prefix = rawmsg[2:space_index-1]
        rest = rawmsg[space_index+1:end]
    else
        prefix = ""
        rest = rawmsg
    end
    command, params_str = split(rest, ' '; limit=2)
    if occursin(" :", params_str)
        params_str, trailing = split(params_str, " :"; limit=2)
        params = split(params_str)
        push!(params, trailing)
    else
        params = split(params_str)
    end

    if command == "PRIVMSG"
        channel, message = params
        sender = get(tags, "display-name") do
            # default value if tag "display-name" is not present
            split(prefix, '!'; limit=2)[1]
        end
        PrivMsg(rawmsg, channel, sender, message, tags)
    else
        Message(rawmsg, prefix, command, params, tags)
    end
end


function connect(
        username="justinfan123",
        password="BLANK",
        server_address="irc.twitch.tv",
        port=6667
)
    sock = Sockets.connect(server_address, port)

    send(msg) = write(sock, "$msg\r\n")

    send("CAP REQ :twitch.tv/commands twitch.tv/tags")
    send("PASS $password")
    send("NICK $username")
    send("USER $username 8 * :$username")

    return sock
end
