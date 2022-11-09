require "socket"

struct Message
  property raw, prefix, command, params, tags

  def initialize(
    @raw : String,
    @prefix : String,
    @command : String,
    @params : Array(String),
    @tags : Hash(String, String)
  )
  end

  def sender
    if display_name = @tags["display-name"]?
      display_name
    else
      @prefix.partition('!')[0]
    end
  end

  def self.parse_tags(tags_str : String)
    tags = {} of String => String
    tags_str.split(';').each do |tag|
      name, _, value = tag.partition('=')
      tags[name] = value
    end
    return tags
  end

  def self.parse(rawmsg : String)
    rawmsg = rawmsg.rstrip
    # the tags are only present if the user requested them by sending
    # "CAP REQ :twitch.tv/commands twitch.tv/tags"
    if rawmsg.starts_with?('@')
      tags_str, _, rawmsg = rawmsg[1..].partition(' ')
      tags = Message.parse_tags(tags_str)
    else
      tags = {} of String => String
    end
    # the rest of the message is parsed according to the rfc:
    # https://datatracker.ietf.org/doc/html/rfc1459#section-2.3
    if rawmsg.starts_with?(':')
      prefix, _, rest = rawmsg[1..].partition(' ')
    else
      prefix = ""
      rest = rawmsg
    end
    command, _, params_str = rest.partition(' ')
    params_str, sep, trailing = params_str.partition(" :")
    params = params_str.split
    params.push(trailing) if sep == " :"
    return Message.new(rawmsg, prefix, command, params, tags)
  end
end

class Bot
  def initialize(
    @addr = "irc.twitch.tv",
    @port = 6667,
    @username = "justinfan123",
    @password = "BLANK"
  )
    @sock = TCPSocket.new
  end

  def send(msg : String)
    @sock.send "#{msg}\r\n"
  end

  def connect(request_tags = true, &)
    @sock.connect(@addr, @port)
    send "PASS #{@password}\r\n"
    send "NICK #{@username}\r\n"
    send "USER #{@username} 8 * #{@username}\r\n"
    send "CAP REQ :twitch.tv/commands twitch.tv/tags" if request_tags
    yield @sock
  ensure
    disconnect unless @sock.closed?
  end

  def disconnect
    @sock.send "QUIT"
    @sock.close
  end

  def join(channel : String)
    send "JOIN ##{chan}"
  end

  def say(target : String, msg : String)
    @sock.send "PRIVMSG #{target} :#{msg}"
  end
end
