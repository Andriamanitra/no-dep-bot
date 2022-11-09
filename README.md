# No dependency chat bots

You can make a pretty good IRC (twitch chat) bot without relying on any 3rd party libraries. This is a great non-trivial but still very simple project that can be implemented relatively quickly in various programming languages to compare them. Even though each of the programs is only around 150 lines of code, they use a variety of different language features: classes, functions, I/O (sockets, files, stdin/stdout), time/string formatting, signal/exception handling, and importing files. The implementations in different languages are kept fairly similar in both structure and behaviour, but there are still differences between how they behave and what features they implement.

All of the code in this repository is released under a permissive licence (no attribution required). Feel free to use them as a starting point for building your own more fully featured chat bots or twitch-integrated games/applications.

## How to run

### Python
`python3 python/main.py`

### Julia
`julia julia/main.jl`

### Crystal
`crystal run crystal/main.cr`

### D
```
dmd -od=d/bin/ -of=d/bin/main d/main.d d/twitchbot.d
./d/bin/main
```

## Features

The features are intentionally kept to a minimum so anyone can read through the code in a few minutes. Implementations in all of the different languages will have at least these basic capabilities:
* Sending and receiving messages (the default `justinfanXXXX` user can only read messages, to send them you need to authenticate)
* Parsing IRC messages into their parts (optional prefix, command, params) according to [RFC1459](https://datatracker.ietf.org/doc/html/rfc1459#section-2.3)
* Handling of Ctrl-C (SIGINT) to quit gracefully

## What is missing

Some things are intentionally left out:
* Perfect error handling – some common errors may be handled but certainly not all of them
* Wrapper classes for all different message types (subscription alerts, follower/subscriber/emote-only mode, bans/timeouts, etc.)
* Anything that would require interacting with the Twitch API
* Dependencies – everything is implemented using only the standard library
