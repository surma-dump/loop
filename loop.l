%{
	#include "loop.tab.h"
	#include <stdio.h>
	#include <stdlib.h>
%}
%%

"#"[^\n]+\n
"LOOP"		{ return LOOPT; }
"r"([0-9])+	{ yylval.reg_num = atoi(yytext+1); return REGISTER; }
";"		{ return SEMICOLON; }
"INC"		{ return INC; }
"DEC"		{ return DEC; }
"{"		{ return LBRACE; }
"}"		{ return RBRACE; }
.	
"\n"

