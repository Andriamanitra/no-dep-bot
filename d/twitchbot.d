import std.socket : TcpSocket, InternetAddress;
import std.string;

class Bot {
public:
    this(InternetAddress addr, string username, string password) {
        _addr = addr;
        this(username, password);
    }

    this(string username, string password) {
        _username = username;
        _password = password;
        this();
    }

    this() {
        _addr = new InternetAddress("irc.twitch.tv", 6667);
        _sock = new TcpSocket();
    }

    bool isConnected() {
        return _sock.isAlive;
    }

    void connect(bool requestTags = true) {
        _sock.connect(_addr);
        _sock.send(
            "PASS " ~ _password ~ "\r\n" ~
                "NICK " ~ _username ~ "\r\n" ~
                "USER " ~ _username ~ " 8 * " ~ _username ~ "\r\n"
        );
        if (requestTags) {
            _sock.send("CAP REQ :twitch.tv/commands twitch.tv/tags\r\n");
        }
    }

    void join(string channelName) {
        _sock.send("JOIN #" ~ channelName ~ "\r\n");
    }

    void say(string target, string msg) {
        _sock.send("PRIVMSG #" ~ target ~ " :" ~ msg);
    }

    void disconnect() {
        _sock.send("QUIT\r\n");
        _sock.close();
    }

    string readLine() {
        assert(_sock.isAlive);
        string line;
        char[1] buf;
        while (_sock.receive(buf) > 0) {
            line ~= buf;
            if (buf[0] == '\n')
                break;
        }
        return line;
    }

protected:
    // justinfan### are special usernames that allow connecting without an account
    string _username = "justinfan1234";
    string _password = "BLANK";
    InternetAddress _addr;
    TcpSocket _sock;
}

struct Message {
    this(string rawMessage) {
        // TODO: this parsing is pretty terrible because it's direct translation
        // from Python, it should be written in a way that suits D better
        rawMessage = rawMessage.stripRight();
        if (rawMessage.startsWith('@')) {
            auto tagsStrAndRaw = rawMessage.splitOnce(" ");
            raw = tagsStrAndRaw[1];
            foreach (tag; tagsStrAndRaw[0].chompPrefix("@").split(';')) {
                auto nameAndValue = tag.splitOnce("=");
                tags[nameAndValue[0]] = nameAndValue[1];
            }
        } else {
            raw = rawMessage;
        }

        string rest;
        if (raw.startsWith(':')) {
            auto prefixAndRest = raw.chompPrefix(":").splitOnce(" ");
            prefix = prefixAndRest[0];
            rest = prefixAndRest[1];
        } else {
            prefix = "";
            rest = raw;
        }

        auto commandAndParamsStr = rest.splitOnce(" ");
        command = commandAndParamsStr[0];
        auto paramsStrAndTrailing = commandAndParamsStr[1].splitOnce(" :");
        params = paramsStrAndTrailing[0].split();
        string trailing = paramsStrAndTrailing[1];
        if (trailing != "") {
            params ~= trailing;
        }
    }

    string raw;
    string prefix;
    string command;
    string[] params;
    string[string] tags;
}

string[2] splitOnce(string s, string sep) {
    string[2] result;
    auto idx = s.indexOf(sep);
    if (idx == -1) {
        result[0] = s;
        result[1] = "";
    } else {
        result[0] = s[0 .. idx];
        result[1] = s[idx + sep.length .. $];
    }
    return result;
}
