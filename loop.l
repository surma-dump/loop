%{
	#include <stdlib.h>
	#include "loop.tab.h"
%}

%%

"#"[^\n]+\n	/* Comment */
"LOOP"		{ return LOOP_STMNT; }
"r"[0-9]+	{ yylval.numeric_val = atoi (yytext + 1); return REGISTER; }
"ADD"		{ return ADD_STMNT; }
"SUB"		{ return SUB_STMNT; }
[0-9]+		{ yylval.numeric_val = atoi (yytext); return CONSTANT; }
"{"		{ return LBRACE; }
"}"		{ return RBRACE; }
";"		{ return SEMICOLON; }
[ \t\n]		/* Eat up whitespaces */
