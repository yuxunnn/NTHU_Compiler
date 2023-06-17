%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define NUMLENGTH 50

char *OPENSCALAR = "<scalar_decl>";
char *CLOSESCALAR = "</scalar_decl>";
char *OPENARRAY = "<array_decl>";
char *CLOSEARRAY = "</array_decl>";
char *OPENFUNCDECL = "<func_decl>";
char *CLOSEFUNCDECL = "</func_decl>";
char *OPENFUNCDEF = "<func_def>";
char *CLOSEFUNCDEF = "</func_def>";
char *OPENEXPR = "<expr>";
char *CLOSEEXPR = "</expr>";
char *OPENSTMT = "<stmt>";
char *CLOSESTMT = "</stmt>";

char *concat(char *s1, char *s2, char *s3, char *s4, char *s5, char *s6, char *s7, char *s8) {
	char *buffer = malloc(strlen(s1)+strlen(s2)+strlen(s3)+strlen(s4)+strlen(s5)+strlen(s6)+strlen(s7)+strlen(s8)+1); 
	sprintf(buffer, "%s%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7, s8);
	return buffer;
}

%}

%union{
    int intVal;
    double douVal;
    char *strVal;
}

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
%type <strVal> arrays_init array_init array array_size array_contents array_elements array_element
%type <strVal> parameters parameter arguments

%type <strVal> expression statement 
%type <strVal> expr14 expr12 expr11 expr10 expr9 expr8 expr7 expr6 expr5 expr4 expr3 expr2 expr1 terminal
%type <strVal> stmts_and_declarations if_else_statement switch_statement while_statement for_statement for_inside return_break_continue_statement compound_statement
%type <strVal> switch_clauses switch_clause switch_clause_statements

%%

S: program {printf("%s", $1);}

program: program variable_declaration {$$ = concat($1, $2, "","","","","","");}
       | program function_declaration {$$ = concat($1, $2, "","","","","","");}
       | program function_definition {$$ = concat($1, $2, "","","","","","");}
       | /* empty */ {$$ = "";}
       ;

variable_declaration: scalar_declaration {$$ = $1;}
                    | array_declaration {$$ = $1;}
                    ;

scalar_declaration: type idents ';' {$$ = concat(OPENSCALAR, $1, $2, $3, CLOSESCALAR, "","","");}
				  ;

type: TYPECONST TYPESIGNED TYPELONG TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, $5, "","","");}
	| TYPECONST TYPESIGNED TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPESIGNED TYPESHORT TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPESIGNED TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, $5, "","","");}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPEUNSIGNED TYPESHORT TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPEUNSIGNED TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPELONG TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPELONG TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPESHORT TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPEINT {$$ = concat($1, $2, "","","","","","");}
	| TYPESIGNED TYPELONG TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPESIGNED TYPELONG TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPESIGNED TYPESHORT TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPESIGNED TYPEINT {$$ = concat($1, $2, "","","","","","");}
	| TYPEUNSIGNED TYPELONG TYPELONG TYPEINT {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPEUNSIGNED TYPELONG TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPEUNSIGNED TYPESHORT TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPEUNSIGNED TYPEINT {$$ = concat($1, $2, "","","","","","");}
	| TYPELONG TYPELONG TYPEINT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPELONG TYPEINT {$$ = concat($1, $2, "","","","","","");}
	| TYPESHORT TYPEINT {$$ = concat($1, $2, "","","","","","");}
	| TYPEINT {$$ = $1;}
	| TYPECONST TYPESIGNED TYPELONG TYPELONG {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPESIGNED TYPELONG {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPESIGNED TYPESHORT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPESIGNED TYPECHAR {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPELONG {$$ = concat($1, $2, $3, $4, "","","","");}
	| TYPECONST TYPEUNSIGNED TYPELONG {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPEUNSIGNED TYPESHORT {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPEUNSIGNED TYPECHAR {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPELONG TYPELONG {$$ = concat($1, $2, $3, "","","","","");}
	| TYPECONST TYPELONG {$$ = concat($1, $2, "","","","","","");}
	| TYPECONST TYPESHORT {$$ = concat($1, $2, "","","","","","");}
	| TYPECONST TYPECHAR {$$ = concat($1, $2, "","","","","","");}
	| TYPESIGNED TYPELONG TYPELONG {$$ = concat($1, $2, $3, "","","","","");}
	| TYPESIGNED TYPELONG {$$ = concat($1, $2, "","","","","","");}
	| TYPESIGNED TYPESHORT {$$ = concat($1, $2, "","","","","","");}
	| TYPESIGNED TYPECHAR {$$ = concat($1, $2, "","","","","","");}
	| TYPEUNSIGNED TYPELONG TYPELONG {$$ = concat($1, $2, $3, "","","","","");}
	| TYPEUNSIGNED TYPELONG {$$ = concat($1, $2, "","","","","","");}
	| TYPEUNSIGNED TYPESHORT {$$ = concat($1, $2, "","","","","","");}
	| TYPEUNSIGNED TYPECHAR {$$ = concat($1, $2, "","","","","","");}
	| TYPELONG TYPELONG {$$ = concat($1, $2, "","","","","","");}
	| TYPELONG {$$ = $1;}
	| TYPESHORT {$$ = $1;}
	| TYPECHAR {$$ = $1;}
	| TYPECONST TYPESIGNED {$$ = concat($1, $2, "","","","","","");}
	| TYPECONST TYPEUNSIGNED {$$ = concat($1, $2, "","","","","","");}
	| TYPECONST TYPEFLOAT {$$ = concat($1, $2, "","","","","","");}
	| TYPECONST TYPEDOUBLE {$$ = concat($1, $2, "","","","","","");}
	| TYPECONST TYPEVOID {$$ = concat($1, $2, "","","","","","");}
	| TYPESIGNED {$$ = $1;}
	| TYPEUNSIGNED {$$ = $1;}
	| TYPEFLOAT {$$ = $1;}
	| TYPEDOUBLE {$$ = $1;}
	| TYPEVOID {$$ = $1;}
	| TYPECONST {$$ = $1;}
	;

idents: idents ',' ident_init {$$ = concat($1, $2, $3, "","","","","");}
      | ident_init {$$ = $1;}
      ;

ident_init: ident '=' expression {$$ = concat($1, $2, $3, "","","","","");}
          | ident {$$ = $1;}
          ;

ident: '*' ID {$$ = concat($1, $2, "","","","","","");}
     | ID {$$ = $1;}
     ;

array_declaration: type arrays_init ';' {$$ = concat(OPENARRAY, $1, $2, $3, CLOSEARRAY, "","","");}
                 ;

arrays_init: arrays_init ',' array_init {$$ = concat($1, $2, $3, "","","","","");}
           | array_init {$$ = $1;}
           ;

array_init: array '=' array_contents {$$ = concat($1, $2, $3, "","","","","");}
          | array {$$ = $1;}
          ;

array: ID array_size {$$ = concat($1, $2, "","","","","","");}
     ;

array_size: array_size '[' expression ']' {$$ = concat($1, $2, $3, $4, "","","","");}
          | '[' expression ']' {$$ = concat($1, $2, $3, "","","","","");}
          ;

array_contents: '{' array_elements '}' {$$ = concat($1, $2, $3, "","","","","");}
              ;

array_elements: array_elements ',' array_element {$$ = concat($1, $2, $3, "","","","","");}
              | array_element {$$ = $1;}
              ;

array_element: array_contents {$$ = $1;}
             | expression {$$ = $1;}
             ;

function_declaration: type ident '(' parameters ')' ';' {$$ = concat(OPENFUNCDECL, $1, $2, $3, $4, $5, $6, CLOSEFUNCDECL);}
                    ;

parameters: parameters ',' parameter {$$ = concat($1, $2, $3, "","","","","");}
          | parameter {$$ = $1;}
          | /* empty */ {$$ = "";}
          ;

parameter: type ident {$$ = concat($1, $2, "","","","","","");}
         ;

function_definition: type ident '(' parameters ')' compound_statement {$$ = concat(OPENFUNCDEF, $1, $2, $3, $4, $5, $6, CLOSEFUNCDEF);}
                   ;

arguments: arguments ',' expression {$$ = concat($1, $2, $3, "","","","","");}
		 | expression {$$ = $1;}
		 | /* empty */ {$$ = "";}
		 ;

expression: expr14 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, "","","","","");}
		  ;

expr14: expr12 '=' expr14 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	  | expr12 {}
	  ;
expr12: expr12 LOGICOR expr11 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	  | expr11 {}
	  ;
expr11: expr11 LOGICAND expr10 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	  | expr10 {}
	  ;
expr10: expr10 '|' expr9 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	  | expr9 {}
	  ;
expr9: expr9 '^' expr8 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr8 {}
	 ;
expr8: expr8 '&' expr7 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr7 {}
	 ;
expr7: expr7 EQUAL expr6 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr7 NOTEQUAL expr6 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr6 {}
	 ;
expr6: expr6 LESSTHAN expr5 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr6 LESSEQUAL expr5 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr6 GREATERTHAN expr5 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr6 GREATEREQUAL expr5 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr5 {}
	 ;
expr5: expr5 LEFTSHIFT expr4 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr5 RIGHTSHIFT expr4 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr4 {}
	 ;
expr4: expr4 '+' expr3 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr4 '-' expr3 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr3 {}
	 ;
expr3: expr3 '*' expr2 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr3 '/' expr2 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr3 '%' expr2 {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, OPENEXPR, $3, CLOSEEXPR, "");}
	 | expr2 {}
	 ;
expr2: INCREMENT expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | DECREMENT expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | '+' expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | '-' expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | '!' expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | '~' expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | '(' type ')' expr2 {$$ = concat($1, $2, $3, OPENEXPR, $4, CLOSEEXPR, "","");}
	 | '(' type '*' ')' expr2 {$$ = concat($1, $2, $3, $4, OPENEXPR, $5, CLOSEEXPR, "");}
	 | '*' expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | '&' expr2 {$$ = concat($1, OPENEXPR, $2, CLOSEEXPR, "","","","");}
	 | expr1 {}
	 ;
expr1: expr1 INCREMENT {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, "","","","");}
	 | expr1 DECREMENT {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, "","","","");}
	 | expr1 '(' arguments ')' {$$ = concat(OPENEXPR, $1, CLOSEEXPR, $2, $3, $4, "","");}
	 | terminal {}
	 ;

terminal: ID {$$ = $1;}
	 	| array {$$ = $1;}
		| INT {
			char *buffer = malloc(NUMLENGTH); 
			sprintf(buffer, "%d", $1);
			$$ = buffer;
		}
		| DOUBLE {
			char *buffer = malloc(NUMLENGTH); 
			sprintf(buffer, "%f", $1);
			$$ = buffer;
		}
		| CHAR {$$ = $1;}
		| STRING {$$ = $1;}
		| NUL {$$ = "0";}
		| '(' expression ')' {$$ = concat($1, $2, $3, "","","","","");}
		;

compound_statement: '{' stmts_and_declarations '}' {$$ = concat($1, $2, $3, "","","","","");}
				  ;

stmts_and_declarations: stmts_and_declarations statement {$$ = concat($1, $2, "","","","","","");} 
					  | stmts_and_declarations variable_declaration {$$ = concat($1, $2, "","","","","","");} 
					  | /* empty */ {$$ = "";}
					  ;

statement: expression ';' {$$ = concat(OPENSTMT, $1, $2, CLOSESTMT, "","","","");}
		 | if_else_statement {$$ = concat(OPENSTMT, $1, CLOSESTMT, "","","","","");}
		 | switch_statement {$$ = concat(OPENSTMT, $1, CLOSESTMT, "","","","","");}
		 | while_statement {$$ = concat(OPENSTMT, $1, CLOSESTMT, "","","","","");}
		 | for_statement {$$ = concat(OPENSTMT, $1, CLOSESTMT, "","","","","");}
		 | return_break_continue_statement {$$ = concat(OPENSTMT, $1, CLOSESTMT, "","","","","");}
		 | compound_statement {$$ = concat(OPENSTMT, $1, CLOSESTMT, "","","","","");}
		 ;

if_else_statement: IF '(' expression ')' compound_statement {$$ = concat($1, $2, $3, $4, $5, "","","");} 
				 | IF '(' expression ')' compound_statement ELSE compound_statement {$$ = concat($1, $2, $3, $4, $5, $6, $7,"");}
				 ;

switch_statement: SWITCH '(' expression ')' '{' switch_clauses '}' {$$ = concat($1, $2, $3, $4, $5, $6, $7,"");}
				;

switch_clauses: switch_clauses switch_clause {$$ = concat($1, $2, "","","","","","");}
			  | /* empty */ {$$ = "";}
			  ;

switch_clause: CASE expression ':' switch_clause_statements {$$ = concat($1, $2, $3, $4, "","","","");} 
			 | DEFAULT ':' switch_clause_statements {$$ = concat($1, $2, $3, "","","","","");}
			 ;

switch_clause_statements: switch_clause_statements statement {$$ = concat($1, $2, "","","","","","");} 
						| /* empty */ {$$ = "";}
						;

while_statement: WHILE '(' expression ')' statement {$$ = concat($1, $2, $3, $4, $5, "","","");}
			   | DO statement WHILE '(' expression ')' ';' {$$ = concat($1, $2, $3, $4, $5, $6, $7,"");}
			   ;

for_statement: FOR '(' for_inside ';' for_inside ';' for_inside ')' statement {
				char *buffer = malloc(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+strlen($8)+strlen($9)+1); 
				sprintf(buffer, "%s%s%s%s%s%s%s%s%s", $1, $2, $3, $4, $5, $6, $7, $8, $9);
				$$ = buffer;
			 }
			 ;

for_inside: expression {$$ = $1;}
		  | /* empty */ {$$ = "";}
		  ;

return_break_continue_statement: RETURN expression ';' {$$ = concat($1, $2, $3, "","","","","");}
							   | RETURN ';' {$$ = concat($1, $2, "","","","","","");}
							   | BREAK ';' {$$ = concat($1, $2, "","","","","","");}
							   | CONTINUE ';' {$$ = concat($1, $2, "","","","","","");}
							   ;

%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}