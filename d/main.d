import std.stdio;
import std.datetime : Clock, SysTime;
import std.string : split;

import twitchbot;

void main() {
    writeln("Which channels to join?");
    string[] channels = readln.split(',');
    Bot bot = new Bot();
    bot.connect();
    foreach (chan; channels) {
        bot.join(chan);
    }
    while (bot.isConnected) {
        string line = bot.readLine();
        if (line == "")
            break;
        Message msg = Message(line);
        if (msg.command == "PRIVMSG") {
            string channel = msg.params[0];
            string sender;
            if ("display-name" in msg.tags) {
                sender = msg.tags["display-name"];
            } else {
                sender = msg.prefix.split('!')[0];
            }
            string content = msg.params[1];
            SysTime dt = Clock.currTime();
            writefln("%-10s [%02d:%02d:%02d] <%s> %s", channel, dt.hour, dt.minute, dt.second, sender, content);
        } else {
            writeln(msg.raw);
        }
    }
}
