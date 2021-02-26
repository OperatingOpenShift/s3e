
SUBDIRS = platform highscore game

all:
	    for dir in $(SUBDIRS); do \
				        $(MAKE) -C $$dir docker-push; \
								    done
