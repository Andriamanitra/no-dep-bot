build: bin/test_parse bin/main

.PHONY: clean
clean:
	rm ./bin/*.o ./bin/main ./bin/test_parse

.PHONY: run
run: bin/main
	./bin/main

bin/main: main.d twitchbot.d
	dmd -od=bin/ -of=bin/main main.d twitchbot.d

bin/test_parse: test_parse.d twitchbot.d
	dmd -od=bin/ -of=bin/test_parse test_parse.d twitchbot.d
