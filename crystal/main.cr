require "./twitchbot.cr"

TIMESTAMP_FMT = Time::Format.new("%H:%M:%S", Time::Location.local)

bot = Bot.new
puts "Which channel(s) to join?"
channels = gets.not_nil!.split(',')
puts "Connecting..."
bot.connect do |sock|
  # Quit with Ctrl+C
  Signal::INT.trap do
    puts "Interrupted by user"
    bot.disconnect
    exit
  end

  channels.each do |chan|
    bot.send "JOIN ##{chan}"
  end

  while rawmsg = sock.gets
    msg = Message.parse(rawmsg)
    if msg.command == "PRIVMSG"
      channel = msg.params[0]
      message = msg.params[1]
      timestamp = TIMESTAMP_FMT.format(Time.utc)
      printf("%10s [%s] <%s> %s\n", channel, timestamp, msg.sender, message)
    else
      puts msg
    end
  end
end
