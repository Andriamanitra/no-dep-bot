import datetime
import sys

from twitchbot import Message, PrivMsg


def showmsg(msg: Message):
    print(f"'{msg.raw}'")
    print(f"    command='{msg.command}'")
    print(f"    prefix='{msg.prefix}'")
    params_str = str(msg.params).replace("'", '"')
    print(f"    params={params_str}")
    print("    tags:")
    for key in sorted(msg.tags):
        val = msg.tags[key]
        print(f"        {key}: '{val}'")


def test_message_parse():
    fname = sys.argv[1]
    with open(fname) as f:
        for line in f:
            msg = Message.parse(line)
            assert type(msg.command) == str
            if isinstance(msg, PrivMsg):
                ts = datetime.datetime.fromisoformat("2006-01-02T15:04:05")
                print(f"{msg.channel:10s} [{ts:%H:%M:%S}] <{msg.sender}> {msg.msg}")
            else:
                showmsg(msg)


if __name__ == "__main__":
    test_message_parse()
