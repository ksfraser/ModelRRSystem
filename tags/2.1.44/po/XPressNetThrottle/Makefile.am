POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/XPressNet/XPressNetThrottle.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/XPressNet/XPressNetThrottle.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 

../../Scripts/XPressNet/XPressNetThrottle.pot: FORCE
	$(MAKE) -C ../../Scripts/XPressNet/ XPressNetThrottle.pot

FORCE:
