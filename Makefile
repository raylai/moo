#	$Id: Makefile,v 1.8 2006/03/06 06:40:59 ray Exp $

PROG=		moo
SRCS=		moo.c scan.c
CPPFLAGS+=	-I${.CURDIR}
COPTS+=		-Wall -W -Wno-unused -Wshadow -pedantic -std=c99
CLEANFILES+=	moo.c y.tab.h scan.c lex.yy.c

LOCALBASE?=/usr/local
BINDIR=${LOCALBASE}/bin
MANDIR=${LOCALBASE}/man/cat

regress::
	cd ${.CURDIR}/regress && ${MAKE} MOO=${.OBJDIR}/moo

.include <bsd.prog.mk>
