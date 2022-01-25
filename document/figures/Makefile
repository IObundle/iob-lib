CC = libreoffice
CFLAGS = --headless --convert-to pdf
LO_RUNNING = $(shell pgrep libreoffice)

LO_FIGS = $(patsubst %.odg,%.pdf,$(wildcard *.odg))
WD_FIGS = $(patsubst %.drom,%.pdf,$(wildcard *.drom))

all: $(LO_FIGS) $(WD_FIGS)

#make libreoffice figures
ifeq ($(LO_RUNNING), )
$(LO_FIGS): %.pdf : %.odg
	$(CC) $(CFLAGS) $<
else 	
$(error LibreOffice is running. Close it before proceeding.)
endif

#make wavedrom figures
$(WD_FIGS): %.pdf : ../figures/%.drom
	npx wavedrom-cli -i $< -s temp.svg
	inkscape --file temp.svg --export-pdf $@
	rm -f temp.svg

clean:
	@rm -f *.pdf *~ $(TD_FIGS)

.PHONY: all clean

