%{
	#include "loop_structs.h"
%}

%union {
	int		number;
	char 		*identifier;
	char		*string;
	struct macro	*macro;
}

%token <number> NUMBER
%token <identifier> IDENTIFIER
%token <string> STRING

%%

MACRODEFINITIONS:
	/* empty */
	| MACRODEFINITION MACRODEFINITIONSS
	;
MACRODEFINITION:
	"#define" IDENTIFIER NUMBER BLOCKCODE
	;
BLOCKCODE:
	"{" CODE "}"
	;
CODE:
    	/* empty */
	| STRING CODE
	| BLOCKCODE CODE
	;

%%

