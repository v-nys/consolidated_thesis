CC      =gcc
CFLAGS  = -g -O -Wuninitialized -Wall
LIBS    = -lm -lzlog -lpthread

OBS	= main.o meter.o read-input.o globals.o logging.o misc.o lower.o raise.o adjust-notes.o
HEADERS	= meter.h logging.h

meter: $(OBS)
#	purify -windows=no -log-file=purify-log $(CC) $(CFLAGS) $(OBS) $(LIBS) -o meter
	$(CC) $(CFLAGS) $(OBS) $(LIBS) -o $(subst src,runtime,$(CURDIR))/meter

$(OBS):	$(HEADERS)

clean: 
	rm -f *.o *~
	echo "Project cleaned."
