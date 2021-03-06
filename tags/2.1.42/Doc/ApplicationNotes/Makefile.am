#* 
#* ------------------------------------------------------------------
#* Makefile.am - Application Notes Makefile
#* Created by Robert Heller on Sun Sep 16 08:26:30 2012
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2012  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 


SUFFIXES        = .tex .sty

AN01Code = AN01.tcl
AN01 = ApplicationNote01
AN01_TEXS = ../MyTitlepage.sty ../MyBibIndex.sty ../titlepage.tex $(AN01).tex \
	AN01_Introduction.tex AN01_TheLayout.tex AN01_TurnoutControl.tex \
	AN01_Signals.tex AN01_Uncouplers.tex AN01_RailDriverInterface.tex \
	AN01_XPressNet.tex AN01_SimpleDispatcher.tex
AN01_FIGS = SwitchTestDemo.pdf SwitchTestDemo-MainInterlocking.png \
	    SwitchTestDemo-DowntownStation.png \
	    SwitchTestDemo-SuburbiaStation.png \
	    SwitchTestDemo-UncouplingRamp.png Quad-Uncoupler-Buffer.pdf \
	    QuadUncouplerBuffer.png
AN01_DEPS = Makefile.am
AN01_PDF = $(AN01).pdf

AN02Code = AN02.tcl
AN02 = ApplicationNote02
AN02_TEXS = ../MyTitlepage.sty ../MyBibIndex.sty ../titlepage.tex $(AN02).tex \
	AN02_Introduction.tex AN02_TheLayout.tex \
	AN02_Turnouts.tex AN02_PowerRelay.tex AN02_Signals.tex \
	AN02_AutoDispatcher.tex
AN02_FIGS = CDblock.png CDtransistor.png SCRPot.png FullWaveSRCThrottle.png \
	4-CDtransistor-on-SB400.pdf TwoSidingOval-N.pdf \
	TwoSidingOval-N-NW-Switch-sig-sensor.pdf  \
	TwoSidingOval-N-NW-sig-sensor-detail.pdf \
	TwoSidingOval-N-East-MRD2.pdf CD-on-SB400.pdf singletrack-ink1.png \
	AN02_schematic_rev.pdf
AN02_DEPS = Makefile.am
AN02_PDF = $(AN02).pdf

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

CLEANFILES = *.aux *.bbl *.blg *.idx *.ilg *.ind *.lof *.lot *.lol *.toc \
		*.log titlepage.tex MRR.bib MyTitlepage.sty \
		$(AN02_PDF) $(AN01_PDF) MyBibIndex.sty

pkgdata_DATA = $(AN01_PDF) $(AN02_PDF) $(AN01Code) $(AN02Code)

EXTRA_DIST = $(AN01_TEXS) $(AN01_FIGS) $(AN01Code) \
	     $(AN02_TEXS) $(AN02_FIGS) $(AN02Code)

BIBLIO = ../MRR.bib


$(AN01_PDF) : $(AN01_TEXS) $(BIBLIO) $(AN01_DEPS) $(AN01_FIGS) $(AN01Code)
	-ln -s $(srcdir)/../titlepage.tex ./titlepage.tex
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	-ln -s $(srcdir)/../MyBibIndex.sty ./
	for f in $(AN01_TEXS) $(AN01Code) $(AN01_FIGS); do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	$(PDFLATEX) $(AN01)
	-$(BIBTEX) $(AN01)
	cp $(top_srcdir)/BuildData/emptyindex.ind $(AN01).ind
	$(PDFLATEX) $(AN01)
	$(MAKEINDEX) $(AN01).idx
	$(PDFLATEX) $(AN01)

$(AN02_PDF) : $(AN02_TEXS) $(BIBLIO) $(AN02_DEPS) $(AN02_FIGS) $(AN02Code)
	-ln -s $(srcdir)/../titlepage.tex ./titlepage.tex
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	-ln -s $(srcdir)/../MyBibIndex.sty ./
	for f in $(AN02_TEXS) $(AN02Code) $(AN02_FIGS); do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	$(PDFLATEX) $(AN02)
	-$(BIBTEX) $(AN02)
	cp $(top_srcdir)/BuildData/emptyindex.ind $(AN02).ind
	$(PDFLATEX) $(AN02)
	$(MAKEINDEX) $(AN02).idx
	$(PDFLATEX) $(AN02)

clean-local:
	for f in $(AN02_TEXS) $(AN02Code) $(AN02_FIGS); do \
	  if test -h "./$$f"; then rm "./$$f"; fi; \
	done
	for f in $(AN01_TEXS) $(AN01Code) $(AN01_FIGS); do \
	  if test -h "./$$f"; then rm "./$$f"; fi; \
	done

