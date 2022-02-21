LO_RUNNING = $(shell pgrep libreoffice)

ODG = $(patsubst %.odg,%.pdf,$(wildcard *.odg))
SVG = $(patsubst %.svg,%.pdf,$(wildcard *.svg))

.PHONY: pb_figs ug_figs clean debug

pb_figs: $(ODG)

ug_figs: $(ODG) $(SVG)

#make libreoffice figures
ifeq ($(LO_RUNNING), )
%.pdf : %.odg
	soffice --headless --convert-to pdf $<
else 	
$(error LibreOffice is running. Close it before proceeding.)
endif

#make wavedrom figures
%.pdf: %.svg
	inkscape --file $< --export-pdf $@

%.svg: %.drom
	npx wavedrom-cli -i $< -s $<

clean:
	@rm -f *.pdf *.svg *~
