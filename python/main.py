import datetime

import twitchbot


def main():
    channels = input("Which channel(s) to connect to?\n> ")
    bot = twitchbot.Bot()
    bot.connect()
    print("Connected!")
    for chan in channels.split(","):
        bot.join(chan)

    try:
        for msg in bot.listen():
            if isinstance(msg, twitchbot.PrivMsg):
                ts = datetime.datetime.now()
                print(f"{msg.channel:10s} [{ts:%H:%M:%S}] <{msg.sender}> {msg.msg}")
            else:
                print(msg)
    except ConnectionError as exc:
        print(exc)
    except KeyboardInterrupt:
        print("Stopping...")
        bot.disconnect()
    except Exception:
        print("An exception was raised, attempting to disconnect...")
        bot.disconnect()
        raise
    print("Disconnected.")


if __name__ == "__main__":
    main()
