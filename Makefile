#Makefile
DOT=dot
SRCDIR=src
BUILDDIR=build
TBLDIR=tbl
FMT=pdf
SCRIPT=./generateDot.sh
FROMTO=$(TBLDIR)/WireLengthTotal.xlsx
CSV=$(FROMTO:%.xlsx=%.csv)
GENSRC=$(SRCDIR)/generated.dot
DOTS=$(wildcard $(SRCDIR)/*.dot)
OUTS=$(DOTS:$(SRCDIR)/%.dot=$(BUILDDIR)/%.$(FMT))
.PHONY:all clean
all: $(BUILDDIR) $(GENSRC) $(DOTS) $(OUTS)
$(BUILDDIR):
	mkdir -p $(BUILDDIR)
$(CSV):$(FROMTO)
	libreoffice --convert-to csv --outdir $(TBLDIR) $<
$(GENSRC):$(SCRIPT) $(CSV)
	$(SCRIPT) -i $(CSV) -o $@
$(BUILDDIR)/%.$(FMT): $(SRCDIR)/%.dot Makefile
	$(DOT) -T$(FMT) $< -o $@ -l shapes/sdl.ps #-n
clean:
	rm -rf $(BUILDDIR)
