#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code.h"

int curr_counter = 0;
int curr_scope = 0;
struct symbol_entry table[MAX_TABLE_SIZE];

char *copys(char *s) {
    char *buffer = malloc(strlen(s)+1);
    strcpy(buffer, s);
    return buffer;
}

int install_symbol(char *s) {
    table[curr_counter].scope = curr_scope;
    table[curr_counter].name = copys(s);
    table[curr_counter].offset = curr_counter;
    table[curr_counter].mode = LOCAL_MODE;

    fprintf(f_asm, "\t/* %s.offset = %d */\n", s, curr_counter);
    fprintf(f_asm, "\taddi sp, sp, -4\n");
    curr_counter++;

    return curr_counter;
}

int set_param_vars(char *functor) {
    int i, j, index, total_args;
    index = look_up_symbol(functor);

    total_args = curr_counter-index-1;
    table[index].total_args = total_args;
    for (j = total_args, i = curr_counter-1; i > index; i--, j--) {
        table[i].scope = curr_scope;
        table[i].offset = j;
        table[i].mode = ARGUMENT_MODE;
    }

    return index;
}

void install_array(char *s, int size) {
    for (int i = 0; i < size; i++) {
        if (i == 0) {
            table[curr_counter].name = copys(s);
        } else {
            table[curr_counter].name = "";
        }
        table[curr_counter].scope = curr_scope;
        table[curr_counter].offset = curr_counter;
        table[curr_counter].mode = LOCAL_MODE;

        fprintf(f_asm, "\t/* a[%d].offset = %d */\n", i, curr_counter);
        fprintf(f_asm, "\taddi sp, sp, -4\n");
        curr_counter++;
    }
}

int look_up_symbol(char *s) {
    int i;
    if (curr_counter == 0) {
        return -1;
    }
    for (i = curr_counter-1; i >= 0; i--) {
        if (!strcmp(s, table[i].name)) {
            return i;
        }
    }

    return -1;
}

void pop_up_symbol(int scope) {
    int i;
    if (curr_counter == 0) {
        return;
    }

    for (i = curr_counter-1; i >= 0; i--) {
        if (table[i].scope != scope) {
            break;
        }
    }

    if (i < 0) {
        curr_counter = 0;
    }
    curr_counter = i+1;
}

void code_gen_func_header(char *functor) {
    fprintf(f_asm, "%s:\n", functor);
    fprintf(f_asm, "\t// BEGIN PROLOGUE\n");
    fprintf(f_asm, "\tsw s0, -4(sp)\n");
    fprintf(f_asm, "\taddi sp, sp, -4\n");
    fprintf(f_asm, "\taddi s0, sp, 0\n");
    fprintf(f_asm, "\tsw sp, -4(s0)\n");
    fprintf(f_asm, "\tsw s1, -8(s0)\n");
    fprintf(f_asm, "\tsw s2, -12(s0)\n");
    fprintf(f_asm, "\tsw s3, -16(s0)\n");
    fprintf(f_asm, "\tsw s4, -20(s0)\n");
    fprintf(f_asm, "\tsw s5, -24(s0)\n");
    fprintf(f_asm, "\tsw s6, -28(s0)\n");
    fprintf(f_asm, "\tsw s7, -32(s0)\n");
    fprintf(f_asm, "\tsw s8, -36(s0)\n");
    fprintf(f_asm, "\tsw s9, -40(s0)\n");
    fprintf(f_asm, "\tsw s10, -44(s0)\n");
    fprintf(f_asm, "\tsw s11, -48(s0)\n");
    fprintf(f_asm, "\taddi sp, s0, -48\n");
    fprintf(f_asm, "\t// END PROLOGUE\n");
    fprintf(f_asm, "\n");
}

void code_gen_at_end_of_function_body() {
    fprintf(f_asm, "\t// BEGIN EPILOGUE\n");
    fprintf(f_asm, "\tlw s11, -48(s0)\n");
    fprintf(f_asm, "\tlw s10, -44(s0)\n");
    fprintf(f_asm, "\tlw s9, -40(s0)\n");
    fprintf(f_asm, "\tlw s8, -36(s0)\n");
    fprintf(f_asm, "\tlw s7, -32(s0)\n");
    fprintf(f_asm, "\tlw s6, -28(s0)\n");
    fprintf(f_asm, "\tlw s5, -24(s0)\n");
    fprintf(f_asm, "\tlw s4, -20(s0)\n");
    fprintf(f_asm, "\tlw s3, -16(s0)\n");
    fprintf(f_asm, "\tlw s2, -12(s0)\n");
    fprintf(f_asm, "\tlw s1, -8(s0)\n");
    fprintf(f_asm, "\tlw sp, -4(s0)\n");
    fprintf(f_asm, "\taddi sp, sp, 4\n");
    fprintf(f_asm, "\tlw s0, -4(sp)\n");
    fprintf(f_asm, "\t// END EPILOGUE\n");
    fprintf(f_asm, "\n");
    fprintf(f_asm, "\tjalr zero, 0(ra)\n");
    fprintf(f_asm, "\n");
}