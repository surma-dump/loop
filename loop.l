%{
	#include <stdlib.h>
	#include "loop.tab.h"
%}


DIGIT		[0-9]
ALPHANUM	[-_a-zA-Z0-9]
ALPHA		[_a-zA-Z]
%%

"#"[^\n]+\n	/* Comment */
"LOOP"		{ return LOOP_STMNT; }
"r"{DIGIT}+	{ yylval.numeric_val = atoi (yytext + 1); return REGISTER; }
"ADD"		{ return ADD_STMNT; }
"SUB"		{ return SUB_STMNT; }
{DIGIT}+	{ yylval.numeric_val = atoi (yytext); return CONSTANT; }
{ALPHA}{ALPHANUM}* { yylval.string = yytext; return MACRONAME; }
"{"		{ return LBRACE; }
"}"		{ return RBRACE; }
"("		{ return LPAREN; }
")"		{ return RPAREN; }
";"		{ return SEMICOLON; }
","		{ return COMMA; }
[ \t\n]		/* Eat up whitespaces */
