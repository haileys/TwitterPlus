TWITTER_PATH = /Applications/Twitter.app/Contents/MacOS/Twitter

OBJECTS = src/main.o src/hackery.o

CFLAGS = -Wno-objc-property-no-attribute -Wno-incomplete-implementation -fPIC -g
LDFLAGS = -dynamiclib -undefined dynamic_lookup

.PHONY: all run

all: twitter_plus.dylib

run: twitter_plus.dylib
	DYLD_INSERT_LIBRARIES=$< $(TWITTER_PATH)

twitter_plus.dylib: $(OBJECTS)
	$(CC) -o $@ $(LDFLAGS) $(CFLAGS) $^

%.o: %.mm src/*.hh
	$(CC) -o $@ $(CFLAGS) -c $<

class_dump.h: $(TWITTER_PATH)
	class-dump $< > $@
