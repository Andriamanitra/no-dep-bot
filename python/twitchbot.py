from __future__ import annotations
import socket
from collections.abc import Iterator
from dataclasses import dataclass


@dataclass
class Message:
    """
    The base class that should be able to handle all messages.
    Common message types like PRIVMSG can subclass this class to
    add extra functionality.
    """
    raw: str
    prefix: str | None
    command: str
    params: list[str]
    tags: dict[str, str]

    @staticmethod
    def parse_tags(rawmsg: str) -> tuple[dict[str, str], str]:
        tags = {}
        if rawmsg.startswith("@"):
            tags_str, _, rawmsg = rawmsg.partition(" ")
            for tag in tags_str.removeprefix("@").split(";"):
                name, _, value = tag.partition("=")
                tags[name] = value
        return tags, rawmsg

    @staticmethod
    def parse(rawmsg: str) -> Message:
        # the tags are only present if the user requested them by sending
        # "CAP REQ :twitch.tv/commands twitch.tv/tags"
        tags, rawmsg = Message.parse_tags(rawmsg.strip())
        # the rest of the message is parsed according to the rfc:
        # https://datatracker.ietf.org/doc/html/rfc1459#section-2.3
        if rawmsg.startswith(":"):
            prefix, _, rest = rawmsg.removeprefix(":").partition(" ")
        else:
            prefix = None
            rest = rawmsg
        command, _, params_str = rest.partition(" ")
        params_str, _, trailing = params_str.partition(" :")
        params = params_str.split()
        if trailing:
            params.append(trailing)

        if command == "PRIVMSG":
            return PrivMsg(rawmsg, prefix, command, params, tags)
        if command == "USERNOTICE":
            return UserNotice(rawmsg, prefix, command, params, tags)
        return Message(rawmsg, prefix, command, params, tags)


class UserNotice(Message):
    """
    Message type for subscriptions, raids, etc.
    docs: https://dev.twitch.tv/docs/irc/commands#usernotice
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.channel = self.params[0]
        self.system_msg = self.tags.get("system-msg", "").replace("\\s", " ")
        self.user_msg = ""
        if len(self.params) > 1:
            self.user_msg = self.params[1]

    def __str__(self) -> str:
        if self.user_msg:
            return f'{self.channel:10s} {self.system_msg} "{self.user_msg}"'
        else:
            return f'{self.channel:10s} {self.system_msg}'


class PrivMsg(Message):
    """
    Message type for chat messages sent to a channel
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        display_name = self.tags.get("display-name")
        if display_name:
            self.sender = display_name
        else:
            self.sender = self.prefix.partition("!")[0]
        self.msg = self.params[-1]
        self.channel = self.params[-2]


class Bot:
    def __init__(self, username="justinfan123"):
        # the username 'justinfan' followed by any number is a special
        # username that can be used to connect to twitch chat without
        # authenticating (read-only, it can't send any messages)
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.username = username

    def connect(
            self,
            server="irc.twitch.tv",
            password="BLANK",
            port=6667,
            request_tags=True
    ):
        self.sock.connect((server, port))
        self.send(f"PASS {password}")
        self.send(f"NICK {self.username}")
        self.send(f"USER {self.username} 8 * :{self.username}")
        if request_tags:
            self.send("CAP REQ :twitch.tv/commands twitch.tv/tags")

    def join(self, channel_name: str):
        self.send(f"JOIN #{channel_name}")

    def listen(self) -> Iterator[Message]:
        while True:
            rcvd = self.sock.recv(4096).decode("utf-8")
            for line in rcvd.splitlines():
                msg = Message.parse(line)
                if msg.command == "PING":
                    self.send(line.replace("PING", "PONG"))
                yield msg

    def say(self, target: str, msg: str):
        self.send(f"PRIVMSG {target} :{msg}")

    def send(self, msg: str):
        self.sock.send(f"{msg}\r\n".encode("utf-8"))

    def disconnect(self):
        self.send("QUIT")
        self.sock.close()
