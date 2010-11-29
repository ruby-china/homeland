## Makefile.am -- Process this file with automake to produce Makefile.in
## Copyright (C) 2000 Gary V. Vaughan
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

MAINTAINERCLEANFILES	= Makefile.in common.h stamp-common
EXTRA_DIST		= common-h.in

AM_CFLAGS 		= -fPIC	
AM_CPPFLAGS		= -fPIC -I$(top_builddir) -I$(top_srcdir) -I$(top_srcdir)/src/css -I$(top_srcdir)/src/utils -D_REENTRANT -D_LARGEFILE64_SOURCE 

pkginclude_HEADERS 	=	css/ICorpusReader.h  css/SegmenterManager.h  css/tolowercase.h css/UnigramRecord.h \
							css/mmthunk.h        css/SegmentPkg.h        css/UnigramCorpusReader.h	\
							css/Segmenter.h      css/SynonymsDict.h      css/UnigramDict.h	\
							utils/csr_mmap.h   utils/darts.h     utils/scoped_ptr.h       utils/Utf8_16.h	\
							utils/csr_assert.h  utils/csr_pool.h   utils/freelist.h  utils/Singleton.h	\
							utils/csr.h         utils/csr_utils.h  utils/os.h        utils/StringTokenizer.h	\
							csr_typedefs.h     css/ThesaurusDict.h             iniparser/dictionary.h \
							iniparser/iniparser.h    utils/bsd_getopt.h    utils/bsd_getopt_win.h


#noinst_HEADERS	= 

## @start 1
lib_LTLIBRARIES         = libmmseg.la
libmmseg_la_LIBADD	= 
libmmseg_la_LDFLAGS = -static
libmmseg_la_SOURCES       =  css/mmthunk.cpp	css/SegmenterManager.cpp  css/SynonymsDict.cpp	\
	css/UnigramDict.cpp css/segmenter.cpp  css/SegmentPkg.cpp \
	css/UnigramCorpusReader.cpp  css/UnigramRecord.cpp	\
	utils/assert.c  utils/bsd_getopt.c  utils/csr_mmap.c  utils/csr_utils.c	utils/Utf8_16.cpp utils/StringTokenizer.cpp iniparser/dictionary.c iniparser/iniparser.c css/ThesaurusDict.cpp

bin_PROGRAMS	= mmseg
mmseg_LDADD	= $(top_builddir)/src/libmmseg.la 
mmseg_SOURCES	= mmseg_main.cpp

## @end 1
## @start 2
# Regenerate common.h with config.status whenever common-h.in changes.
common.h: stamp-common
	@:
stamp-common: $(srcdir)/common-h.in $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES= CONFIG_HEADERS= CONFIG_OTHER=sic/common.h \
	  $(SHELL) ./config.status
	echo timestamp > $@
## @end 2

# Don't distribute common.h, since it is build host dependent!
dist-hook:
	rm -f $(distdir)/common.h
