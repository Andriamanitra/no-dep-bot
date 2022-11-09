require "./twitchbot.cr"

TIMESTAMP_FMT = Time::Format.new("%H:%M:%S", Time::Location.local)

def showmsg(msg : Message)
  puts "'#{msg.raw}'"
  puts "    command='#{msg.command}'"
  puts "    prefix='#{msg.prefix}'"
  puts "    params=#{msg.params}"
  puts "    tags:"
  msg.tags.keys.sort.each do |key|
    val = msg.tags[key]
    puts "        #{key}: '#{val}'"
  end
end

ARGF.each_line do |line|
  msg = Message.parse(line)
  if msg.command == "PRIVMSG"
    channel = msg.params[0]
    message = msg.params[1]
    timestamp = TIMESTAMP_FMT.format(Time.parse_iso8601("2006-01-02T15:04:05Z"))
    printf("%10s [%s] <%s> %s\n", channel, timestamp, msg.sender, message)
  else
    showmsg(msg)
  end
end
