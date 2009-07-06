#include <stdio.h>
#include "loop_def.h"

unsigned int* regs ;

void run(struct loop_cmd* p) {
	int i, old_reg;
	while (p) {
		switch (p->op) {
			case nINC:
				regs[p->reg]++ ;
				break;
			case nDEC:
				if (regs[p->reg] != 0) 
					regs[p->reg]-- ;
				break;
			case nLOOP:
				old_reg = regs[p->reg] ;
				for(i=0; i < old_reg; i++) {
					run(p->loop) ;
				}				
				break;
		}
		p = p->next ;
	}
}
