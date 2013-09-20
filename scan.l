%{
/*	$Id: scan.l,v 1.4 2006/06/16 07:32:27 ray Exp $	*/

/*
 * Written by Raymond Lai <ray@cyth.net>.
 * Public domain.
 */

#include <sys/param.h>
#include <sys/stdint.h>

#include <stdlib.h>

#include "extern.h"
#include "y.tab.h"

%}

%option yylineno noyywrap nounput

%%

[0-9]+ {
	yylval.number = getnum(yytext);
	return (INTEGER);
}

0x[0-9a-fA-F]+ {
	yylval.number = getnum(yytext);
	return (INTEGER);
}

0b[01]+ {
	yylval.number = getbin(yytext);
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
