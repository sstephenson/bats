RONN := ronn
PAGES := bats.1 bats.7

all: $(PAGES)

bats.1: bats.1.ronn
	$(RONN) -r $<

bats.7: bats.7.ronn
	$(RONN) -r $<
