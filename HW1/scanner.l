%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

bool source_flag = true;
bool token_flag = true;
char current_line[305];

void print_token(char *token) {
    printf("#%s:%s\n", token, yytext);
    return;
}

void print_source() {
    printf("%d:%s", yylineno-1, current_line);
    return;
}

void record_source() {
    strcat(current_line, yytext);
    return;
}

%}

%option yylineno

%x                  COMMENT
%x                  COMMENTS

Keywords            "for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"float"|"char"|"const"|"signed"|"unsigned"|"short"|"long"
Macros              "NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN"
Identifiers         [_a-zA-Z][_a-zA-Z0-9]*
Operators           "+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"&"|"|"
Punctuations        ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"
Integer             [+-]?[0-9]+
Floating            [+-]?[0-9]+"."[0-9]*|[+-]?[0-9]*"."[0-9]+
Char                \'(\\.|[^'\\])\'|\'"\\"[0-7]{1,3}\'|\'"\\x"[0-9A-Fa-f]+\'|\'"\\u"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\'|\'"\\U"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\'
String              \"(\\.|[^"\\])*\"

SourceOn            "#pragma"[ \t]+"source"[ \t]+"on"
SourceOff           "#pragma"[ \t]+"source"[ \t]+"off"
TokenOn             "#pragma"[ \t]+"token"[ \t]+"on"
TokenOff            "#pragma"[ \t]+"token"[ \t]+"off"

Others              .

%%

"\n"                {record_source(); if (source_flag) {print_source();}; strcpy(current_line, "");}
<COMMENTS>"\n"      {record_source(); if (source_flag) {print_source();}; strcpy(current_line, "");}

{Keywords}          {record_source(); if (token_flag) {print_token("key");}}
{Macros}            {record_source(); if (token_flag) {print_token("macro");}}
{Identifiers}       {record_source(); if (token_flag) {print_token("id");}}
{Operators}         {record_source(); if (token_flag) {print_token("op");}}
{Punctuations}      {record_source(); if (token_flag) {print_token("punc");}}
{Integer}           {record_source(); if (token_flag) {print_token("integer");}}
{Floating}          {record_source(); if (token_flag) {print_token("float");}}
{Char}              {record_source(); if (token_flag) {print_token("char");}}
{String}            {record_source(); if (token_flag) {print_token("string");}}

{SourceOn}          {record_source(); source_flag = true;}
{SourceOff}         {record_source(); source_flag = false;}
{TokenOn}           {record_source(); token_flag = true;}
{TokenOff}          {record_source(); token_flag = false;}

"//".*              {record_source();}
"//".*"\\\n"        {record_source(); if (source_flag) {print_source();}; strcpy(current_line, ""); BEGIN COMMENT;}
<COMMENT>"\\\n"     {record_source(); if (source_flag) {print_source();}; strcpy(current_line, "");}
<COMMENT>"\n"       {record_source(); if (source_flag) {print_source();}; strcpy(current_line, ""); BEGIN 0;}

"/*"                {record_source(); BEGIN COMMENTS;}
<COMMENTS>"*/"      {record_source(); BEGIN 0;}

{Others}            {record_source();}
<COMMENT>{Others}   {record_source();}
<COMMENTS>{Others}  {record_source();}

%%