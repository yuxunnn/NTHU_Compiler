%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code.h"

FILE *f_asm;
int curr_arguments_index;
int branch_count = 0;

%}

%union{
    int intVal;
    double douVal;
    char *strVal;
}

%token <strVal> LOW HIGH

%token <strVal> TYPECONST TYPESIGNED TYPEUNSIGNED TYPELONG TYPESHORT TYPEINT TYPECHAR TYPEFLOAT TYPEDOUBLE TYPEVOID

%token <strVal> IF ELSE
%token <strVal> SWITCH CASE DEFAULT
%token <strVal> WHILE DO
%token <strVal> FOR
%token <strVal> RETURN BREAK CONTINUE
%token <strVal> NUL

%token <strVal> ID
%token <intVal> INT
%token <douVal> DOUBLE
%token <strVal> CHAR
%token <strVal> STRING

%token <strVal> '+' '-' '*' '/' '%' '=' '!' '~' '^' '&' '|'
%token <strVal> ':' ';' ',' '.' '[' ']' '(' ')' '{' '}'
%token <strVal> INCREMENT DECREMENT 
%token <strVal> LESSTHAN LESSEQUAL GREATERTHAN GREATEREQUAL EQUAL NOTEQUAL
%token <strVal> LOGICAND LOGICOR
%token <strVal> RIGHTSHIFT LEFTSHIFT

%start S
%type <strVal> S program
%type <strVal> type
%type <strVal> variable_declaration function_declaration function_definition
%type <strVal> scalar_declaration array_declaration
%type <strVal> idents ident_init ident
%type <strVal> arrays_init array_init
%type <strVal> parameters parameter arguments

%type <strVal> expression statement 
%type <strVal> expr2 expr1 terminal
%type <strVal> stmts_and_declarations if_else_statement switch_statement while_statement for_statement for_inside return_break_continue_statement compound_statement
%type <strVal> switch_clauses switch_clause switch_clause_statements

%right '='
%left EQUAL NOTEQUAL
%left LESSTHAN LESSEQUAL GREATERTHAN GREATEREQUAL
%left RIGHTSHIFT LEFTSHIFT
%left '+' '-'
%left '*' '/' '%'

%%

S: program {}

program: program variable_declaration {}
       | program function_declaration {}
       | program function_definition {}
       | /* empty */ {$$ = "";}
       ;

variable_declaration: scalar_declaration {}
                    | array_declaration {}
                    ;

scalar_declaration: type idents ';' {}
				  ;

type: TYPECONST TYPESIGNED TYPELONG TYPELONG TYPEINT {}
	| TYPECONST TYPESIGNED TYPELONG TYPEINT {}
	| TYPECONST TYPESIGNED TYPESHORT TYPEINT {}
	| TYPECONST TYPESIGNED TYPEINT {}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPELONG TYPEINT {}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPEINT {}
	| TYPECONST TYPEUNSIGNED TYPESHORT TYPEINT {}
	| TYPECONST TYPEUNSIGNED TYPEINT {}
	| TYPECONST TYPELONG TYPELONG TYPEINT {}
	| TYPECONST TYPELONG TYPEINT {}
	| TYPECONST TYPESHORT TYPEINT {}
	| TYPECONST TYPEINT {}
	| TYPESIGNED TYPELONG TYPELONG TYPEINT {}
	| TYPESIGNED TYPELONG TYPEINT {}
	| TYPESIGNED TYPESHORT TYPEINT {}
	| TYPESIGNED TYPEINT {}
	| TYPEUNSIGNED TYPELONG TYPELONG TYPEINT {}
	| TYPEUNSIGNED TYPELONG TYPEINT {}
	| TYPEUNSIGNED TYPESHORT TYPEINT {}
	| TYPEUNSIGNED TYPEINT {}
	| TYPELONG TYPELONG TYPEINT {}
	| TYPELONG TYPEINT {}
	| TYPESHORT TYPEINT {}
	| TYPEINT {}
	| TYPECONST TYPESIGNED TYPELONG TYPELONG {}
	| TYPECONST TYPESIGNED TYPELONG {}
	| TYPECONST TYPESIGNED TYPESHORT {}
	| TYPECONST TYPESIGNED TYPECHAR {}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPELONG {}
	| TYPECONST TYPEUNSIGNED TYPELONG {}
	| TYPECONST TYPEUNSIGNED TYPESHORT {}
	| TYPECONST TYPEUNSIGNED TYPECHAR {}
	| TYPECONST TYPELONG TYPELONG {}
	| TYPECONST TYPELONG {}
	| TYPECONST TYPESHORT {}
	| TYPECONST TYPECHAR {}
	| TYPESIGNED TYPELONG TYPELONG {}
	| TYPESIGNED TYPELONG {}
	| TYPESIGNED TYPESHORT {}
	| TYPESIGNED TYPECHAR {}
	| TYPEUNSIGNED TYPELONG TYPELONG {}
	| TYPEUNSIGNED TYPELONG {}
	| TYPEUNSIGNED TYPESHORT {}
	| TYPEUNSIGNED TYPECHAR {}
	| TYPELONG TYPELONG {}
	| TYPELONG {}
	| TYPESHORT {}
	| TYPECHAR {}
	| TYPECONST TYPESIGNED {}
	| TYPECONST TYPEUNSIGNED {}
	| TYPECONST TYPEFLOAT {}
	| TYPECONST TYPEDOUBLE {}
	| TYPECONST TYPEVOID {}
	| TYPESIGNED {}
	| TYPEUNSIGNED {}
	| TYPEFLOAT {}
	| TYPEDOUBLE {}
	| TYPEVOID {}
	| TYPECONST {}
	;

idents: idents ',' ident_init {}
      | ident_init {}
      ;

ident_init: ident '=' expression {
			int index = look_up_symbol($1);
			fprintf(f_asm, "\t/* ident_init %s */\n", $1);
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\tsw t0, %d(s0)\n", table[index].offset * (-4) - 48);
		  }
          | ident {}
          ;

ident: '*' ID {
		install_symbol($2);
		$$ = $2;
	 }
     | ID {
		install_symbol($1);
		$$ = $1;
	 }
     ;

array_declaration: type arrays_init ';' {}
                 ;

arrays_init: arrays_init ',' array_init {}
           | array_init {}
           ;

array_init: ID '[' INT ']' {
			install_array($1, $3);
		  }
		  ;

function_declaration: type ID '(' parameters ')' ';' {
						fprintf(f_asm, ".global %s\n", $2);
					}
                    ;

parameters: parameters ',' parameter {}
          | parameter {}
          | /* empty */ {$$ = "";}
          ;

parameter: type ident {}
		 ;


function_definition: type ID '(' parameters ')' {
						curr_scope ++;
				   		set_param_vars($2);
						code_gen_func_header($2);
				   } compound_statement {
						pop_up_symbol(curr_scope);
						code_gen_at_end_of_function_body();
						curr_scope --;
				   }
                   ;

arguments: arguments ',' expression {
			fprintf(f_asm, "\t/* argument */\n");
			fprintf(f_asm, "\tlw a%d, 0(sp)\n", curr_arguments_index);
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			curr_arguments_index ++;
		 }
		 | expression {
			fprintf(f_asm, "\t/* argument */\n");
			fprintf(f_asm, "\tlw a%d, 0(sp)\n", curr_arguments_index);
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			curr_arguments_index ++;
		 }
		 | /* empty */ {$$ = "";}
		 ;

expression: ID '=' expression {
			int index = look_up_symbol($1);
			fprintf(f_asm, "\t/* expr = expr */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tsw t0, %d(s0)\n", table[index].offset * (-4) - 48);
		  }
		  | '*' ID '=' expression {
			int index = look_up_symbol($2);
			fprintf(f_asm, "\t/* *expr = expr */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");

			fprintf(f_asm, "\tlw t1, %d(s0)\n", table[index].offset * (-4) - 48);
			fprintf(f_asm, "\tadd t1, t1, s0\n");

			fprintf(f_asm, "\tsw t0, 0(t1)\n");
		  }
		  | ID '[' expression ']' '=' expression {
			int index = look_up_symbol($1);
			fprintf(f_asm, "\t/* array = expr */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");

			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			
			fprintf(f_asm, "\tli t2, 4\n");
			fprintf(f_asm, "\tmul t1, t2, t1\n");
			fprintf(f_asm, "\tsub t1, s0, t1\n");
			fprintf(f_asm, "\tsw t0, %d(t1)\n", table[index].offset * (-4) - 48);
		  }
		  | expression EQUAL expression {
			fprintf(f_asm, "\t/* lessthan */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbeq t1, t0, body%d\n", branch_count);
			fprintf(f_asm, "\tjal zero, exit%d\n", branch_count);
		  }
		  | expression NOTEQUAL expression {
			fprintf(f_asm, "\t/* lessthan */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbne t1, t0, body%d\n", branch_count);
			fprintf(f_asm, "\tjal zero, exit%d\n", branch_count);
		  }
		  | expression LESSTHAN expression {
			fprintf(f_asm, "\t/* lessthan */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tblt t1, t0, body%d\n", branch_count);
			fprintf(f_asm, "\tjal zero, exit%d\n", branch_count);
		  }
		  | expression LESSEQUAL expression {
			fprintf(f_asm, "\t/* lessthan */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tble t1, t0, body%d\n", branch_count);
			fprintf(f_asm, "\tjal zero, exit%d\n", branch_count);
		  }
		  | expression GREATERTHAN expression {
			fprintf(f_asm, "\t/* lessthan */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbgt t1, t0, body%d\n", branch_count);
			fprintf(f_asm, "\tjal zero, exit%d\n", branch_count);
		  }
		  | expression GREATEREQUAL expression {
			fprintf(f_asm, "\t/* lessthan */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbge t1, t0, body%d\n", branch_count);
			fprintf(f_asm, "\tjal zero, exit%d\n", branch_count);
		  }
		  | expression LEFTSHIFT expression {

		  }
		  | expression RIGHTSHIFT expression {

		  }
		  | expression '+' expression {
			fprintf(f_asm, "\t/* add */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tadd t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '-' expression {
			fprintf(f_asm, "\t/* sub */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tsub t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '*' expression {
			fprintf(f_asm, "\t/* mul */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tmul t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '/' expression {
			fprintf(f_asm, "\t/* div */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tdiv t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '%' expression {
			fprintf(f_asm, "\t/* rem */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\trem t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expr2 {}
		  ;
		  
expr2: INCREMENT expr2 {}
	 | DECREMENT expr2 {}
	 | '+' expr2 {
		fprintf(f_asm, "\t/* unary add */\n");
		fprintf(f_asm, "\tlw t0, 0(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, 4\n");
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");	
	 }
	 | '-' expr2 {
		fprintf(f_asm, "\t/* unary sub */\n");
		fprintf(f_asm, "\tlw t0, 0(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, 4\n");
		fprintf(f_asm, "\tsub t0, zero, t0\n");
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
	 }
	 | '*' expr2 {
		int index = look_up_symbol($2);
		fprintf(f_asm, "\t/* *id */\n");
		fprintf(f_asm, "\tlw t0, %d(s0)\n", table[index].offset * (-4) - 48);
		fprintf(f_asm, "\tadd t0, t0, s0\n");
		fprintf(f_asm, "\tlw t0, 0(t0)\n");
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
	 }
	 | '&' expr2 {
		int index = look_up_symbol($2);
		fprintf(f_asm, "\t/* &id */\n");
		fprintf(f_asm, "\tli t0, %d\n", table[index].offset * (-4) - 48);
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
	 }
	 | expr1 {}
	 ;

expr1: expr1 INCREMENT {}
	 | expr1 DECREMENT {}
	 | ID {
		curr_arguments_index = 0;
	 } '(' arguments ')' {
		fprintf(f_asm, "\t/* function */\n");
		fprintf(f_asm, "\tsw ra, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
		fprintf(f_asm, "\tjal ra, %s\n", $1);
		fprintf(f_asm, "\tlw ra, 0(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, 4\n");
	 }
	 | terminal {}
	 ;

terminal: ID {
			int index = look_up_symbol($1);
			fprintf(f_asm, "\t/* id %s */\n", $1);
			fprintf(f_asm, "\tlw t0, %d(s0)\n", table[index].offset * (-4) - 48);
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| INT {
			fprintf(f_asm, "\t/* int %d */\n", $1);
			fprintf(f_asm, "\tli t0, %d\n", $1);
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| ID '[' expression ']' {
			int index = look_up_symbol($1);
			fprintf(f_asm, "\t/* array */\n");
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");

			fprintf(f_asm, "\tli t1, 4\n");
			fprintf(f_asm, "\tmul t0, t1, t0\n");
			fprintf(f_asm, "\tsub t0, s0, t0\n");
			
			fprintf(f_asm, "\tlw t0, %d(t0)\n", table[index].offset * (-4) - 48);
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| LOW {
			fprintf(f_asm, "\t/* LOW */\n");
			fprintf(f_asm, "\tli t0, 0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| HIGH {
			fprintf(f_asm, "\t/* HIGH */\n");
			fprintf(f_asm, "\tli t0, 1\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| '(' expression ')' {}
		| DOUBLE {}
		| CHAR {}
		| STRING {}
		| NUL {}
		;

compound_statement: '{' stmts_and_declarations '}' {}
				  ;

stmts_and_declarations: stmts_and_declarations statement {} 
					  | stmts_and_declarations variable_declaration {} 
					  | /* empty */ {$$ = "";}
					  ;

statement: expression ';' {}
		 | if_else_statement {}
		 | switch_statement {}
		 | while_statement {}
		 | for_statement {}
		 | return_break_continue_statement {}
		 | compound_statement {}
		 ;

if_else_statement: IF '(' expression ')' compound_statement {} 
				 | IF '(' expression ')' compound_statement ELSE compound_statement {}
				 ;

switch_statement: SWITCH '(' expression ')' '{' switch_clauses '}' {}
				;

switch_clauses: switch_clauses switch_clause {}
			  | /* empty */ {$$ = "";}
			  ;

switch_clause: CASE expression ':' switch_clause_statements {} 
			 | DEFAULT ':' switch_clause_statements {}
			 ;

switch_clause_statements: switch_clause_statements statement {} 
						| /* empty */ {$$ = "";}
						;

while_statement: WHILE '(' expression ')' statement {}
			   | DO statement WHILE '(' expression ')' ';' {}
			   ;

for_statement: FOR {
				fprintf(f_asm, ".global condition%d\n", branch_count);
				fprintf(f_asm, ".global body%d\n", branch_count);
				fprintf(f_asm, ".global after%d\n", branch_count);
				fprintf(f_asm, ".global exit%d\n", branch_count);
			 } '(' for_inside ';' {
				fprintf(f_asm, "condition%d:\n", branch_count);
			 } for_inside ';' {
				fprintf(f_asm, "after%d:\n", branch_count);
			 } for_inside ')' {
				fprintf(f_asm, "\tjal zero, condition%d\n", branch_count);
				fprintf(f_asm, "body%d:\n", branch_count);
			 } statement {
				fprintf(f_asm, "\tjal zero, after%d\n", branch_count);
				fprintf(f_asm, "exit%d:\n", branch_count);
				branch_count ++;
			 }
			 ;

for_inside: expression {}
		  | /* empty */ {$$ = "";}
		  ;

return_break_continue_statement: RETURN expression ';' {}
							   | RETURN ';' {}
							   | BREAK ';' {}
							   | CONTINUE ';' {}
							   ;

%%

int main(void) {
	f_asm = fopen("codegen.S", "w");
    yyparse();
	fclose(f_asm);
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}