%{
/*	$Id: scan.l,v 1.3 2006/03/04 07:12:52 ray Exp $	*/

/*
 * Written by Raymond Lai <ray@cyth.net>.
 * Public domain.
 */

#include <stdlib.h>

#include "extern.h"
#include "y.tab.h"

/*
 * XXX - Some code on the internet suggested I put this:
 * 	extern YYSTYPE yylval;
 * but that doesn't work.  Otto's code doesn't need this, why does mine?
 */
extern int yylval;

%}

%%

[0-9]+ {
	yylval = getnum(yytext);
	return (INTEGER);
}

0x[0-9a-fA-F]+ {
	yylval = getnum(yytext);
	return (INTEGER);
}

0b[01]+ {
	yylval = getbin(yytext);
	return (INTEGER);
}

"<"	return (LT);
">"	return (GT);
"<="	return (LE);
">="	return (GE);
"=="	return (EQ);
"!="	return (NEQ);
"<<"	return (LS);
">>"	return (RS);
"||"	return (LOR);
"&&"	return (LAND);

[-+*/%()^|!~&\n]	return (*yytext);

[ \t]	; /* skip whitespace */

.	; /* skip everything else */

%%

int yywrap(void) {
	return (1);
}
