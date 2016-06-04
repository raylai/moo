%{
/*
 * Written by Raymond Lai <ray@cyth.net>.
 * Public domain.
 */

#include <stdint.h>
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

"<="	return (LE);
">="	return (GE);
"<"	return (LT);
">"	return (GT);
"=="	return (EQ);
"!="	return (NEQ);
"<<"	return (LS);
">>"	return (RS);
"||"	return (LOR);
"&&"	return (LAND);
"+"	return (PLUS);
"-"	return (MINUS);
"*"	return (TIMES);
"/"	return (DIV);
"%"	return (MOD);
"("	return (LPAREN);
")"	return (RPAREN);
"^"	return (XOR);
"|"	return (BOR);
"&"	return (BAND);
"!"	return (NOT);
"~"	return (INVERSE);
"\n"	return (NL);

[ \t]	; /* skip whitespace */

%%
