%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "loop.h"

	struct macro *macrolist ;
%}

%union {
	int		number;
	char		*string;
	struct macro	*macro;
}

%token <number> NUMBER
%token <string> STRING
%token <string> IDENTIFIER

%type <macro> MACRODEFINITIONS
%type <macro> MACRODEFINITION

%%

MACRODEFINITIONS:
	/* empty */ { $$ = NULL; } ;
	| MACRODEFINITION MACRODEFINITIONS {
		$$ = $1;
		$1->next = $2;
		macrolist = $$ ;
	}
	;
MACRODEFINITION:
	"#define" IDENTIFIER NUMBER "{" STRING "}" {
		printf("Found a macro \"%s\"\n", $2) ;
		$$ = _CALLOC(struct macro,1);
		$$->name = $2;
		$$->num_parameters = $3;
		$$->code = $5;
	}
	;

%%

yyerror(char *s) {
	fprintf(stderr,"%s\n",s);
}

int main()
{
	struct macro *tmp;
	printf("Starting parser\n");
	yyparse();
	printf("Macrolist: %x\n", macrolist);

	tmp = macrolist;
	while (tmp) {
		printf("%s %d => %s\n",tmp->name,tmp->num_parameters,tmp->code);
	}

	while (macrolist) {
		tmp = macrolist;
		macrolist = macrolist->next;
		free(tmp);
	}
}
