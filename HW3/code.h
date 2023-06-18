#define MAX_TABLE_SIZE 5000

/* mode */
#define GLOBAL_MODE 1
#define LOCAL_MODE 2
#define ARGUMENT_MODE 3

extern struct symbol_entry {
    char *name;
    int scope;
    int offset;
    int total_args;
    int total_locals;
    int mode;
} table[MAX_TABLE_SIZE];

int install_symbol(char *s);
int set_param_vars(char *functor);

void install_array(char *s, int size);

int look_up_symbol(char *s);
void pop_up_symbol(int scope);
void code_gen_func_header(char *functor);
void code_gen_at_end_of_function_body();

extern int curr_counter;
extern int curr_scope;
extern FILE *f_asm;