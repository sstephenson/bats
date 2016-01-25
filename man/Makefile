RONN := bundle exec ronn
PAGES := man1/bats.1 man7/bats.7

all: $(PAGES)

man1/bats.1: man1/bats.1.ronn
	$(RONN) -r $<

man7/bats.7: man7/bats.7.ronn
	$(RONN) -r $<
