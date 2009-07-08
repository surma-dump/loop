%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define MAX(a,b) ((a>b)?a:b)
	#define _CALLOC(s,c) (s*)calloc(c,sizeof(s))
	#define DEBUG fprintf(stderr,"%d\n",__LINE__)

	enum {
		OP_ADD,
		OP_SUB,
		OP_LOOP,
		OP_NOP,
		OP_MACRO
	} ;

	struct cmd {
		int op ;
		union {
			int reg ;
			struct register_list *reglist ;
		} ;
		union {
			struct cmd *loop ;
			unsigned int param ;
			struct macro* macro ;
		} ;
		struct cmd *next ;
	} ;

	struct register_list {
		int reg ;
		struct register_list* next;
	} ;

	struct macro {
		char *name ;
		struct register_list *reglist ;
		struct cmd *macrocode ;
		struct macro *next ;
	} ;

	struct cmd *cmd_first = (struct cmd*) 0 ;
	struct macro *macro_first = (struct macro*) 0 ;
	struct register_list empty_list ;
	unsigned int regs_used ;
	unsigned int *regs ;
	extern FILE* yyin ;


	void prepare() ;
	void run(struct cmd*) ;
	void linkedlist_teardown(struct cmd*) ;
	void teardown() ;
	void dump_registers() ;
	struct macro* find_loop_macro(const char*) ;
%}

%right	<irrelevant>	SEMICOLON
%right	<irrelevant>	COMMA
%token	<cmd_ptr>	LOOP_STMNT
%token	<numeric_val>	REGISTER
%token	<string>	MACRONAME
%token	<irrelevant>	LBRACE
%token	<irrelevant>	RBRACE
%token	<irrelevant>	LPAREN
%token	<irrelevant>	RPAREN
%token	<cmd_ptr>	ADD_STMNT
%token	<cmd_ptr>	SUB_STMNT
%token	<numeric_val>	CONSTANT
%type	<cmd_ptr>	LOOP_PROG
%type	<reglist_ptr>	REGISTERLIST
%type	<macro>		MACRODEF
%type	<macro>		MACRODEFS

%union {
	int		numeric_val ;
	void		*irrelevant ;
	char		*string ;
	struct cmd	*cmd_ptr ;
	struct register_list
			*reglist_ptr ;
	struct macro	*macro ;
}

%%

LOOP_FILE:
	MACRODEFS LOOP_PROG {
		macro_first = $1 ;
		cmd_first = $2 ;
	}
;

MACRODEFS:
	/* empty */ { $$ = macro_first ; }
	| MACRODEF MACRODEFS {
		$1->next = $2 ;
		$$ = $1 ;
		
	}
;

MACRODEF:
	MACRONAME LPAREN REGISTERLIST RPAREN LBRACE LOOP_PROG RBRACE {
		$$ = _CALLOC(struct macro,1) ;
		$$->name = $1 ;
		$$->reglist = $3 ;
		$$->macrocode = $6 ;
		$$->next = (struct macro*) 0 ;
	}
;

REGISTERLIST: 
	/* empty */ { $$ = &empty_list }
	| REGISTER {
		$$ = _CALLOC(struct register_list,1) ;
		$$->reg = $1 ;
		$$->next = (struct register_list*) 0 ;
	}
	| REGISTER COMMA REGISTERLIST {
		$$ = _CALLOC(struct register_list,1) ;
		$$->reg = $1 ;
		$$->next = $3 ;
	}
;

LOOP_PROG: 
	/* empty */ {
		$$ = _CALLOC(struct cmd,1) ;
		$$->op = OP_NOP ;
	} 
	| ADD_STMNT REGISTER CONSTANT {
		regs_used = MAX(regs_used, $2) ;
		$$ = _CALLOC(struct cmd,1) ;
		$$->op = OP_ADD ;
		$$->reg = $2 ;
		$$->param = $3 ;
	} 
	| SUB_STMNT REGISTER CONSTANT {
		regs_used = MAX(regs_used, $2) ;
		$$ = _CALLOC(struct cmd,1) ;
		$$->op = OP_SUB ;
		$$->reg = $2 ;
		$$->param = $3 ;
	} 
	| LOOP_STMNT REGISTER LBRACE LOOP_PROG RBRACE {
		regs_used = MAX(regs_used, $2) ;
		$$ = _CALLOC(struct cmd,1) ;
		$$->op = OP_LOOP ;
		$$->reg = $2 ;
		$$->loop = $4 ;
	}
	| LOOP_PROG SEMICOLON LOOP_PROG {
		$1->next = $3 ;
		$$ = $1 ;
	}
	| MACRONAME LPAREN REGISTERLIST RPAREN {
		$$ = _CALLOC(struct cmd,1);
		$$->op = OP_MACRO ;
		$$->reglist = $3 ;
		struct macro *m = find_loop_macro($1) ;
		if (m == (struct macro*) 0) {
			yyerror("Unknown macro name found") ;
			YYERROR ;
		}
		$$->macro = m ;
	}
;

%%

yyerror(char *s) {
	printf("Error: %s",s) ;
}

void prepare() {

	regs = _CALLOC(unsigned int,regs_used+1) ;
	memset (regs, 0, regs_used+1) ;
}

struct macro* find_loop_macro(const char* name) {
	struct macro* m = macro_first  ;
	struct macro* res = (struct macro*) 0;
	while (m) {
		if(strcmp (m->name, name) == 0) 
			res = m ;
		m = m->next ;
	} 
	return res ;
}

void run(struct cmd* p) {
	unsigned int cnt ;
	struct macro* m ;
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
			case OP_NOP:
			break;
			case OP_MACRO:
				if (p->macro->reglist != &empty_list) {
				}
				run(p->loop) ;
			break;
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
	linkedlist_teardown(cmd_first) ;
}

int main(int argc, char **argv) {

	argc--; argv++;
	if (argc > 0)
		yyin = fopen (argv[0],"r") ;
	else	
		yyin = stdin ;

	yyparse() ;

//	prepare() ;
//	run(cmd_first) ;
//	dump_registers() ;
//	teardown() ;

}

