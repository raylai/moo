%{
/*
 * Written by Raymond Lai <ray@cyth.net>.
 * Public domain.
 */

#include <ctype.h>
#include <err.h>
#include <errno.h>
#include <inttypes.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "extern.h"

extern FILE *yyin;
static int bflag;
static int print_hex;
static int print_dec;
static int print_oct;
static int print_bin;
static int print_signed;
static int print_unsigned;
static uint tokens;
static int used_bin;
static int used_dec;
static int used_hex;
static int used_oct;

static void		divbyzero(void);
static void		printnum(int64_t);
__dead static void	usage(void);
void			yyerror(char *);
int			yylex(void);
int			yyparse(void);
%}

%union {
	int64_t	 number;
}

%token INTEGER EQ NEQ NL LS RS LPAREN RPAREN
%left LOR
%left LAND
%left BOR
%left XOR
%left BAND
%left EQ NEQ
%left LT GT LE GE
%left LS RS
%left PLUS MINUS
%left TIMES DIV MOD
%right NOT INVERSE
%type <number>	INTEGER
%type <number>	expr

%%
program:
	program expr NL		{
					if (used_hex || used_dec ||
					    used_oct || used_bin)
						printnum($2);
					tokens = used_hex = used_dec =
					    used_oct = used_bin = 0;
				}
	|
	| error NL		{ yyerrok; }
	;

expr:
	INTEGER			{ $$ = $1; tokens++; }
	| expr PLUS expr	{ $$ = $1 + $3; tokens++; }
	| expr MINUS expr	{ $$ = $1 - $3; tokens++; }
	| expr TIMES expr	{ $$ = $1 * $3; tokens++; }
	| expr DIV expr		{
					if ($3 == 0)
						divbyzero();
					else {
						$$ = $1 / $3;
						tokens++;
					}
				}
	| expr MOD expr		{
					if ($3 == 0)
						divbyzero();
					else {
						$$ = $1 % $3;
						tokens++;
					}
				}
	| expr BAND expr	{ $$ = $1 & $3; tokens++; }
	| expr XOR expr		{ $$ = $1 ^ $3; tokens++; }
	| expr BOR expr		{ $$ = $1 | $3; tokens++; }
	| expr LAND expr	{ $$ = $1 && $3; tokens++; }
	| expr LOR expr		{ $$ = $1 || $3; tokens++; }
	| expr EQ expr		{ $$ = $1 == $3; tokens++; }
	| expr NEQ expr		{ $$ = $1 != $3; tokens++; }
	| expr LT expr		{ $$ = $1 < $3; tokens++; }
	| expr GT expr		{ $$ = $1 > $3; tokens++; }
	| expr LE expr		{ $$ = $1 <= $3; tokens++; }
	| expr GE expr		{ $$ = $1 >= $3; tokens++; }
	| expr LS expr		{ $$ = $1 << $3; tokens++; }
	| expr RS expr		{ $$ = $1 >> $3; tokens++; }
	| INVERSE expr		{ $$ = ~$2; tokens++; }
	| NOT expr		{ $$ = !$2; tokens++; }
	| MINUS expr %prec TIMES{ $$ = -$2; tokens++; }
	| LPAREN expr RPAREN	{ $$ = $2; tokens += 2; }
	;
%%

void
divbyzero(void)
{
	warnx("divide by zero");
	/* Don't print anything. */
	used_hex = used_dec = used_oct = used_bin = 0;
}

void
yyerror(char *s)
{
	fprintf(stderr, "%s\n", s);
}

/*
 * Print numbers in bases that were input or in bases that were specified.
 */
static void
printnum(int64_t num)
{
	int printed;

/* Print tabs between numbers as necessary. */
#define printspace() do {	\
	if (printed++)		\
		printf("\t");	\
} while (0)

	printed = 0;
	/* If no bases were specified, print the ones that were input. */
	if (!bflag) {
		/* If only one term was entered, print it in all bases */
		if (tokens == 1)
			print_hex = print_dec = print_oct = print_bin = 1;
		else {
			/* Reset print flags. */
			print_hex = print_dec = print_oct = print_bin = 0;
			if (used_hex)
				print_hex = 1;
			if (used_dec)
				print_dec = 1;
			if (used_oct)
				print_oct = 1;
			if (used_bin)
				print_bin = 1;
			/* Reset used flags. */
			used_hex = used_dec = used_oct = used_bin = 0;
		}
	}

	if (print_hex) {
		printspace();
		printf("0x%" PRIx64, num);
	}
	if (print_dec) {
		if (print_unsigned) {
			printspace();
			printf("%" PRIu64, num);
		}
		if (print_signed) {
			printspace();
			printf("%" PRId64, num);
		}
	}
	if (print_oct) {
		printspace();
		printf("0%" PRIo64, num);
	}
	if (print_bin) {
		int bit, printed_bit;

		printed_bit = 0;

		printspace();
		printf("0b");
		for (bit = sizeof(num) * 8; bit > 0; --bit)
			if (num & (1LL << (bit - 1))) {
				printf("1");
				++printed_bit;
			/* Print leading zeroes if any bits were printed. */
			} else {
				if (printed_bit) {
					printf("0");
					++printed_bit;
				}
			}
		/*
		 * If no bits were printed out (num == 0) then print a 0
		 * so we don't just print ``0b''.
		 */
		if (!printed_bit)
			printf("0");
	}

	printf("\n");
	return;

TOOLONG:
	errx(1, "format string too long");
}

/*
 * Read binary number string and convert to int.
 */
int64_t
getbin(const char *nptr)
{
	int64_t num;
	const char *p;

	used_bin = 1;

	if (strncmp("0b", nptr, 2) != 0)
		errx(2, "not a binary number: %s", nptr);

	/* XXX - buffer overflow */
	for (p = nptr + 2, num = 0; *p != '\0'; ++p) {
		num <<= 1;

		switch (*p) {
		case '1':
			++num;
			/* FALLTHROUGH */
		case '0':
			break;
		default:
			errx(2, "not a binary number: %s", nptr);
		}
	}

	return (num);
}

/*
 * Accept hex, decimal, and octal integers.
 */
int64_t
getnum(const char *nptr)
{
	int64_t num;
	char *ep;
	int64_t lval;

	errno = 0;
	lval = strtoll(nptr, &ep, 0);
	if (*nptr == '\0' || *ep != '\0')
		errx(1, "invalid number: %s", nptr);
	if ((errno == ERANGE && (lval == LLONG_MAX || lval == LLONG_MIN)) ||
	    (lval > INT64_MAX || lval < INT64_MIN))
		errx(1, "out of range: %s", nptr);
	num = lval;

	if (strncmp(nptr, "0x", 2) == 0)
		used_hex = 1;
	else if (nptr[0] == '0' && nptr[1] != '\0')
		used_oct = 1;
	else
		used_dec = 1;

	return (num);
}

int
main(int argc, char *argv[])
{
	int ch;

	while ((ch = getopt(argc, argv, "0123456789b:suw:")) != -1)
		switch (ch) {
		/*
		 * If we get a numerical flag it may be a negative
		 * number, so pop the argument back in and let the
		 * argument parser handle it.
		 */
		case '0': case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			--optind;
			goto DONEPARSING;
		case 'b':
			bflag = 1;
			if (optarg[0] == 'a') {
				print_hex = print_dec = print_oct =
				    print_bin = 1;
				break;
			}
			/* Only allow certain bases to be printed. */
			switch (getnum(optarg)) {
			case 16:
				print_hex = 1;
				break;
			case 10:
				print_dec = 1;
				break;
			case 8:
				print_oct = 1;
				break;
			case 2:
				print_bin = 1;
				break;
			default:
				errx(1, "invalid base: %s", optarg);
			}
			break;
		case 's':
			print_signed = 1;
			break;
		case 'u':
			print_unsigned = 1;
			break;
		default:
			usage();
		}
DONEPARSING:
	argc -= optind;
	argv += optind;

	/* Print signed decimal numbers by default. */
	if (!(print_signed || print_unsigned))
		print_signed = 1;

	/* If arguments were given calculate arguments instead of stdin. */
	if (argc > 0) {
		FILE *sfp;
		int fd, i;
		char *sfn;

		if (asprintf(&sfn, "%s/moo.XXXXXXXXXX",
		    getenv("TMPDIR") ? getenv("TMPDIR") : "/tmp") == -1)
			err(1, "asprintf");
		if ((fd = mkstemp(sfn)) == -1 ||
		    (sfp = fdopen(fd, "w+")) == NULL) {
			warn("%s", sfn);
			if (fd != -1)
				unlink(sfn);
			exit(1);
		}
		if (unlink(sfn) == -1)
			warn("%s", sfn);

		/* Copy arguments to temp file. */
		for (i = 0; i < argc; ++i)
			if (fputs(argv[i], sfp))
				err(1, "error writing %s", sfn);
		/* Parser needs a newline at end. */
		if (fputs("\n", sfp))
			err(1, "error writing %s", sfn);
		free(sfn);

		rewind(sfp);
		yyin = sfp;
	}

	yyparse();

	return (0);
}

void
usage(void)
{
	extern char *__progname;

	fprintf(stderr, "usage: %s [-su] [-b base] expr\n",
	    __progname);
	exit(1);
}
