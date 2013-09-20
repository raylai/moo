#	$Id: Makefile,v 1.4 2006/03/04 23:36:46 ray Exp $

PROG=		moo
SRCS=		moo.c scan.c
CPPFLAGS+=	-I${.CURDIR}
COPTS+=		-Wall -W -Wno-unused
CLEANFILES+=	moo.c y.tab.h scan.c lex.yy.c

LOCALBASE?=/usr/local
BINDIR=${LOCALBASE}/bin
MANDIR=${LOCALBASE}/man/cat

.include <bsd.prog.mk>
