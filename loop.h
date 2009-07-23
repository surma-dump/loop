#ifndef LOOP_H
#define LOOP_H

#define _CALLOC(a,b) (a*) calloc(b,sizeof(a))


struct macro {
	char		*name;
	int 		num_parameters;
	char		*code;
	struct macro	*next;
};
#endif
