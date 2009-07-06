#define MAX(a,b) (a>b)?a:b;
enum {
	nINC,
	nDEC,
	nLOOP
} ;
struct loop_cmd {
	int op ;
	int reg ;
	struct loop_cmd *loop ;
	struct loop_cmd *next ;
};

void run(struct loop_cmd* p) ;

extern unsigned int* regs;
