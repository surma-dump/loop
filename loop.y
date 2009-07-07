%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define MAX(a,b) ((a>b)?a:b)

	enum {
		OP_ADD,
		OP_SUB,
		OP_LOOP
	} ;

	struct cmd {
		int op ;
		int reg ;
		union {
			struct cmd *loop ;
			unsigned int param ;
		} ;
		struct cmd *next ;
	} ;

	struct cmd *first ;
	unsigned int regs_used ;
	unsigned int *regs ;
	extern FILE* yyin ;
%}

%right	<irrelevant>	SEMICOLON
%token	<cmd_ptr>	LOOP_STMNT
%token	<numeric_val>	REGISTER
%token	<irrelevant>	LBRACE
%token	<irrelevant>	RBRACE
%token	<cmd_ptr>	ADD_STMNT
%token	<cmd_ptr>	SUB_STMNT
%token	<numeric_val>	CONSTANT
%type	<cmd_ptr>	LOOP_PROG

%union {
	int		numeric_val ;
	void		*irrelevant ;
	struct cmd	*cmd_ptr ;
}

%%


LOOP_PROG: 
	ADD_STMNT REGISTER CONSTANT {
		regs_used = MAX(regs_used, $2) ;
		$$ = (struct cmd*) malloc (sizeof (struct cmd)) ;
		$$->op = OP_ADD ;
		$$->reg = $2 ;
		$$->param = $3 ;
		first = $$ ;
	} 
	| SUB_STMNT REGISTER CONSTANT {
		regs_used = MAX(regs_used, $2) ;
		$$ = (struct cmd*) malloc (sizeof (struct cmd)) ;
		$$->op = OP_SUB ;
		$$->reg = $2 ;
		$$->param = $3 ;
		first = $$ ;
	} 
	| LOOP_STMNT REGISTER LBRACE LOOP_PROG RBRACE {
		regs_used = MAX(regs_used, $2) ;
		$$ = (struct cmd*) malloc (sizeof (struct cmd)) ;
		$$->op = OP_LOOP ;
		$$->reg = $2 ;
		$$->loop = $4 ;
		first = $$ ;
	}
	| LOOP_PROG SEMICOLON LOOP_PROG {
		$1->next = $3 ;
		$$ = $1 ;
		first = $$ ;
	}
;

%%

yyerror(char *s) {
	printf("Error: %s",s) ;
}

void prepare() {

	regs = (unsigned int*) calloc (regs_used, sizeof(unsigned int)) ;
	memset (regs, 0, regs_used) ;
}

void run(struct cmd* p) {
	//struct cmd *p = prog ;
	unsigned int cnt ;
	do {
		switch(p->op) {
			case OP_ADD:
				regs[p->reg] += p->param ;
			break;
			case OP_SUB:
				if (regs[p->reg] > p->param)
					regs[p->reg] -= p->param ;
			break;
			case OP_LOOP:
				for (cnt = regs[p->reg] ; cnt > 0 ; cnt--) 
					run(p->loop) ;
			break ;
		}
		p = p->next ;
	} while (p) ;
}

void dump_registers() {
	int i;
	for (i = 0 ; i <= regs_used ; i++) 
		printf("Register[%02d]: %d\n", i, regs[i]) ;
}

void linkedlist_teardown (struct cmd* p) {
	struct cmd* cur ;
	do {
		
		cur = p ;
		p = p->next ;

		if (cur->op == OP_LOOP) 
			linkedlist_teardown (cur->loop) ;

		free (cur) ;
	} while (p) ;		
}

void teardown() {
	free (regs) ;
	linkedlist_teardown(first) ;
}

int main(int argc, char **argv) {

	argc--; argv++;
	if (argc > 0)
		yyin = fopen (argv[0],"r") ;
	else	
		yyin = stdin ;

	yyparse() ;

	prepare() ;
	run(first) ;
	dump_registers() ;
	teardown() ;
	
}

