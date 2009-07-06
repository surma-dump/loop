%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "loop_def.h"

	int reg_used = 0;
	struct loop_cmd* last ;
	#define YSSTYPE int	
	extern FILE* yyin;
%}


%union {
	int			reg_num;
	struct loop_cmd* 	cmd;
	int			irrev;
}

%token	<reg_num>	REGISTER
%token	<irrev>		INC DEC
%token	<irrev>		SEMICOLON
%token	<irrev>		LBRACE RBRACE
%token	<irrev>		LOOPT
%type	<cmd>		LOOP_CMD
%type	<cmd>		LOOP_CMD_SEQ
%type	<cmd>		INC_CMD
%type	<cmd>		DEC_CMD
%type	<cmd>		LOOP

%%
LOOP_CMD_SEQ: LOOP_CMD {
		$1->next = (struct loop_cmd*)0 ;
		$$ = $1 ;
	}
	| LOOP_CMD LOOP_CMD_SEQ {
		$1->next = $2 ;
		$$ = $1 ;
		last = $1;
	}
;

LOOP_CMD: INC_CMD		{ $$ = $1 }
	| DEC_CMD		{ $$ = $1 }
	| LOOP			{ $$ = $1 } 
;

INC_CMD: INC REGISTER SEMICOLON { 
		reg_used = MAX(reg_used, $2); 
		$$ = (struct loop_cmd*) malloc (sizeof(struct loop_cmd)) ;
		$$->op = nINC ;
		$$->reg = $2 ;
	}
;

DEC_CMD: DEC REGISTER SEMICOLON { 
		reg_used = MAX(reg_used, $2); 
		$$ = (struct loop_cmd*) malloc (sizeof(struct loop_cmd)) ;
		$$->op = nDEC ;
		$$->reg = $2 ;
	}
;

LOOP: LOOPT REGISTER LBRACE LOOP_CMD_SEQ RBRACE { 
		reg_used = MAX(reg_used, $2);
		$$ = (struct loop_cmd*) malloc (sizeof(struct loop_cmd)) ;
		$$->op = nLOOP ;
		$$->reg = $2 ;
		$$->loop = $4 ;
	} 
;

%%

yyerror(char* s) {
	printf ("ERROR: %s\n", s) ;
}
int main(int argc, char** argv) {
	int i;
	argc-- ; argv++ ;
	if (argc > 0) 
		yyin = fopen (argv[0],"r") ;
	else
		yyin = stdin ;
	yyparse() ;
	regs = (unsigned int*) calloc (reg_used, sizeof(unsigned int)) ;
	run(last) ;
	for (i = 0; i<=reg_used; i++) 
		printf ("Register r%02d: %d\n", i, regs[i]) ;
}
