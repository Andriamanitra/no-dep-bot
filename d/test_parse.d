import twitchbot;
import std.stdio;
import std.string : split;
import std.conv : to;
import std.algorithm : sort;
import std.datetime : SysTime, DateTime;

void main(string[] argv) {
    string fname = argv[1];
    foreach (line; File(fname).byLine) {
        string lineStr = line.to!string;
        auto msg = Message(lineStr);
        if (msg.command == "PRIVMSG") {
            string channel = msg.params[0];
            string sender;
            if ("display-name" in msg.tags) {
                sender = msg.tags["display-name"];
            } else {
                sender = msg.prefix.split('!')[0];
            }
            string content = msg.params[1];
            SysTime dt = SysTime(DateTime(2006, 1, 2, 15, 4, 5));
            writefln("%-10s [%02d:%02d:%02d] <%s> %s", channel, dt.hour, dt.minute, dt.second, sender, content);
        } else {
            writefln("'%s'", msg.raw);
            writefln("    command='%s'", msg.command);
            writefln("    prefix='%s'", msg.prefix);
            writefln("    params=%s", msg.params);
            writeln("    tags:");
            foreach (key; sort(msg.tags.keys)) {
                writefln("        %s: '%s'", key, msg.tags[key]);
            }
        }
    }
}
