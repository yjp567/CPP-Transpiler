%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "lex.yy.c"

extern FILE *yyin;  // Declare yyin for file input
extern int yylex();  // Declare yylex to call lexer manually

FILE *out_file;  // Declare out_file for output file
FILE *parser_log;

char int_type[10] = "int";
char float_type[7] = "float";

int yyerror(char *s) {
    printf("%s\n", s);
    return 0;
}
%}

%union {
    int intval;
    float floatval;
    char *str;
}

%token <str> INTEGER_CONST DOUBLE_CONST VARIABLE LEFT_SQUARE RIGHT_SQUARE LEFT_CURLY RIGHT_CURLY LEFT_PAREN RIGHT_PAREN COLON SEMI_COLON LESS_THAN GREATER_THAN QUESTION_MARK COMMA SET IF ELSE SIZE LOOP FINALLY RETURN FUNC PRINT SMALL BIG INTEGER FLOAT VOID RIGHT_ARROW LEFT_ARROW ADD_OP SUB_OP MUL_OP DIV_OP REM_OP BIT_OR BIT_AND BIT_XOR BIT_NOT OR AND NOT LESS_THAN_EQUAL GREATER_THAN_EQUAL NOT_EQUAL ASSIGN

%type <str> program setup_section main_section setup_statement set_stat stat_list func_stat_list func_stat statement type var_declaration var_list var_list_assign expression expr_list func_def param_list type_all push_back push_front pop_back pop_front cond_stat else_if predicate loop_stat init update print_stat

%type <str> func_line loop_line cond_line

%start program

%left OR
%left AND
%left BIT_OR
%left BIT_XOR
%left BIT_AND
%left NOT_EQUAL LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL 
%left ADD_OP SUB_OP
%left MUL_OP DIV_OP REM_OP
%right BIT_NOT
%right NOT
%right ASSIGN
%nonassoc LEFT_PAREN RIGHT_PAREN

%%

// Grammar rules go here

program: setup_section main_section 
        {
            $$ = (char*) malloc(strlen($1) + strlen($2) + 64);
            sprintf($$, "#include <bits/stdc++.h>\n\nusing namespace std;\n\n%s\n%s", $1, $2);
            fprintf(out_file, "%s", $$);
            printf("Program parsed successfully\n");
        }
       ;

func_line: { fprintf(parser_log, "%d : Function Declaration\n", lineno); };

loop_line: { fprintf(parser_log, "%d : Loop Statement\n", lineno); };

cond_line: { fprintf(parser_log, "%d : Conditional Statement\n", lineno); };

setup_section: setup_statement setup_section
               {
                   $$ = (char*) malloc(strlen($1) + strlen($2) + 16);
                   sprintf($$, "%s\n%s", $1, $2);    
               }
            |  { $$ = (char*) malloc(2); sprintf($$, " "); }
            ;

main_section: stat_list 
              {
                  $$ = (char*) malloc(strlen($1) + 32);
                  sprintf($$, "int main()\n{\n%s\nreturn 0;\n}", $1);
              }
            | { $$ = (char*) malloc(2); sprintf($$, " "); }
            ;

setup_statement: set_stat 
                 {
                    $$ = (char*) malloc(strlen($1));
                    sprintf($$, "%s", $1);
					fprintf(parser_log, "%d : Set Statement\n", lineno);
                 }
               | func_line func_def
                 {
                    $$ = (char*) malloc(strlen($2));
                    sprintf($$, "%s", $2);
                 }
               ;

set_stat: SET type SMALL SEMI_COLON 
         {
            $$ = (char*) malloc(2);
            sprintf($$, " ");
         }
        | SET type BIG SEMI_COLON
        {
            $$ = (char*) malloc(128);
            if (strcmp($2, "int") == 0)
            {
                strcpy(int_type, "long long");
            }
            else
            {
                strcpy(float_type, "double");
            }
        }
        ;

stat_list: stat_list statement
           {
               $$ = (char*) malloc(strlen($1) + strlen($2) + 16);
               sprintf($$, "%s\n%s", $1, $2);   
           }
         | statement
           {
               $$ = (char*) malloc(strlen($1) + 16);
               sprintf($$, "%s", $1);
           }
         ;

func_stat_list: func_stat_list func_stat
                {
                    $$ = (char*) malloc(strlen($1) + strlen($2) + 16);
                    sprintf($$, "%s\n%s", $1, $2);
                }
              | 
                {
                    $$ = (char*) malloc(2);
                    sprintf($$, " ");
                }
              ;

func_stat: statement
           {
               $$ = (char*) malloc(strlen($1) + 16);
               sprintf($$, "%s", $1);
           }
         | RETURN expression SEMI_COLON
           {
               $$ = (char*) malloc(strlen($2) + 16);
                sprintf($$, "return %s;", $2);
				fprintf(parser_log, "%d : Return Statement\n", lineno);
           }
         | RETURN SEMI_COLON
           {
               $$ = (char*) malloc(16);
               sprintf($$, "return;");
			   fprintf(parser_log, "%d : Return Statement\n", lineno);
           }
         | RETURN VOID SEMI_COLON
           {
              $$ = (char*) malloc(16);
              sprintf($$, "return;");
			  fprintf(parser_log, "%d : Return Statement\n", lineno);
           }
         ;

statement : var_declaration SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Variable Declaration\n", lineno);
            }
          | var_list_assign SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Assignment Statement\n", lineno);
            }
          | cond_line cond_stat
            {
                $$ = (char*) malloc(strlen($2) + 16);
                sprintf($$, "%s\n", $2);
				// fprintf(parser_log, "%d : Conditional Statement\n", lineno);
            }
          | loop_line loop_stat
            {
                $$ = (char*) malloc(strlen($2) + 16);
                sprintf($$, "%s\n", $2);
				// fprintf(parser_log, "%d : Loop Statement\n", lineno);
            }
          | push_back SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Push/Pop Statement\n", lineno);
            }
          | push_front SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Push/Pop Statement\n", lineno);
            }
          | pop_back SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Push/Pop Statement\n", lineno);
            }
          | pop_front SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Push/Pop Statement\n", lineno);
            }
          | print_stat SEMI_COLON
            {
                $$ = (char*) malloc(strlen($1) + 16);
                sprintf($$, "%s;", $1);
				fprintf(parser_log, "%d : Print Statement\n", lineno);
            }
        
          ;

type: INTEGER { $$ = (char*) malloc(16); sprintf($$, "%s", int_type);}
    | FLOAT   { $$ = (char*) malloc(16); sprintf($$, "%s", float_type); }
    ;

var_declaration: type var_list_assign 
                 {
                     $$ = (char*) malloc(strlen($1) + strlen($2) + 16);
                     sprintf($$, "%s %s", $1, $2);
                 }
               | LEFT_SQUARE type RIGHT_SQUARE var_list
                 {
                     $$ = (char*) malloc(strlen($2) + strlen($4) + 16);
                     sprintf($$, "vector<%s> %s", $2, $4);
                 }
               | LEFT_CURLY type COLON type_all RIGHT_CURLY var_list
                 {
                    $$ = (char*) malloc(strlen($2) + strlen($4) + strlen($6) + 16);
                    sprintf($$, "map <%s, %s> %s", $2, $4, $6);
                 }
               ;

var_list: VARIABLE COMMA var_list 
          {
              $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
              sprintf($$, "%s, %s", $1, $3);  
          }
        | VARIABLE { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
        ;

var_list_assign: VARIABLE ASSIGN expression COMMA var_list_assign
                 {
                     $$ = (char*) malloc(strlen($1) + strlen($3) + strlen($5) + 16);
                     sprintf($$, "%s = %s, %s", $1, $3, $5);
                 }
               | VARIABLE COMMA var_list_assign
                 {
                     $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                     sprintf($$, "%s, %s", $1, $3);
                 }
               | VARIABLE ASSIGN expression
                 {
                     $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                     sprintf($$, "%s = %s", $1, $3);
                 }
               | VARIABLE { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
               | VARIABLE LEFT_SQUARE expression RIGHT_SQUARE ASSIGN expression COMMA var_list_assign
                 {
                     $$ = (char*) malloc(strlen($1) + strlen($3) + strlen($6) + strlen($8) + 16);
                     sprintf($$, "%s[%s] = %s, %s", $1, $3, $6, $8);
                 }
                 | VARIABLE LEFT_SQUARE expression RIGHT_SQUARE ASSIGN expression
				  {
					 $$ = (char*) malloc(strlen($1) + strlen($3) + strlen($6) + 16);
					 sprintf($$, "%s[%s] = %s", $1, $3, $6);
				  }
               ;

expression: expression ADD_OP expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s + %s", $1, $3);
            }
          | expression SUB_OP expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s - %s", $1, $3);
            }
          | expression MUL_OP expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s * %s", $1, $3);
            }
          | expression DIV_OP expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s / %s", $1, $3);
            }
          | expression REM_OP expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s %% %s", $1, $3);
            }
          | expression BIT_OR expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s | %s", $1, $3);
            }
          | expression BIT_AND expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s & %s", $1, $3);
            }
          | expression BIT_XOR expression
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s ^ %s", $1, $3);
            }
          | BIT_NOT expression
            {
                $$ = (char*) malloc(strlen($2) + 16);
                sprintf($$, "~%s", $2);
            }
          | LEFT_PAREN expression RIGHT_PAREN
            {
                $$ = (char*) malloc(strlen($2) + 16);
                sprintf($$, "(%s)", $2);
            }
          | INTEGER_CONST { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
          | DOUBLE_CONST  { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
          | VARIABLE      { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
          | SUB_OP LEFT_PAREN expression RIGHT_PAREN
            {
                $$ = (char*) malloc(strlen($3) + 16);
                sprintf($$, "-(%s)", $3);
            }
          | SUB_OP VARIABLE
            {
                $$ = (char*) malloc(strlen($2) + 16);
                sprintf($$, "-%s", $2);
            }
          | SUB_OP INTEGER_CONST { $$ = (char*) malloc(strlen($2) + 16); sprintf($$, "-%s", $2); }
          | SUB_OP DOUBLE_CONST  { $$ = (char*) malloc(strlen($2) + 16); sprintf($$, "-%s", $2); }
          | VARIABLE LEFT_SQUARE expression RIGHT_SQUARE
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s[%s]", $1, $3);
            }
          | SIZE LEFT_SQUARE VARIABLE RIGHT_SQUARE
            {
                $$ = (char*) malloc(strlen($3) + 16);
                sprintf($$, "%s.size()", $3);
            }
          | VARIABLE LEFT_PAREN expr_list RIGHT_PAREN
            {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s(%s)", $1, $3);
            }
         
          ;

expr_list: expression COMMA expr_list
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s, %s", $1, $3);
           }
         | expression { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1);}
         ;

func_def: FUNC VARIABLE LEFT_PAREN param_list SEMI_COLON type_all RIGHT_PAREN LESS_THAN func_stat_list GREATER_THAN
          {
              $$ = (char*) malloc(strlen($2) + strlen($4) + strlen($6) + strlen($9) + 16);
              sprintf($$, "%s %s(%s)\n{\n%s\n}", $6, $2, $4, $9);
          }
        ;

param_list: type_all VARIABLE COMMA param_list
            {
                $$ = (char*) malloc(strlen($1) + strlen($2) + strlen($4) + 16);
                sprintf($$, "%s %s, %s", $1, $2, $4);
            }
          | type_all VARIABLE
            {
                $$ = (char*) malloc(strlen($1) + strlen($2) + 16);
                sprintf($$, "%s %s", $1, $2);
            }
          ;

type_all: type { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
        | LEFT_SQUARE type_all RIGHT_SQUARE
          {
              $$ = (char*) malloc(strlen($2) + 16);
              sprintf($$, "vector<%s>", $2);
          }
        | LEFT_CURLY type COLON type_all RIGHT_CURLY
          {
              $$ = (char*) malloc(strlen($2) + strlen($4) + 16);
              sprintf($$, "map <%s, %s>", $2, $4);
          } 
        | VOID { $$ = (char*) malloc(16); sprintf($$, "void"); }
        ;

push_back: VARIABLE LEFT_ARROW LEFT_SQUARE expression RIGHT_SQUARE
           {
               $$ = (char*) malloc(strlen($1) + strlen($4) + 16);
               sprintf($$, "%s.push_back(%s)", $1, $4);
           }
         ;

push_front: LEFT_SQUARE expression RIGHT_SQUARE RIGHT_ARROW VARIABLE
            {
                $$ = (char*) malloc(strlen($2) + 2*strlen($5) + 16);
                sprintf($$, "%s.insert(%s.begin(), %s)", $5, $5, $2);
            }
          ;

pop_back: VARIABLE RIGHT_ARROW LEFT_SQUARE VARIABLE RIGHT_SQUARE
          {
              $$ = (char*) malloc(2*strlen($1) + strlen($4) + 16);
              sprintf($$, "%s = %s.back();\n%s.pop_back();", $4, $1, $1);
          }
        | VARIABLE RIGHT_ARROW LEFT_SQUARE RIGHT_SQUARE
          {
              $$ = (char*) malloc(strlen($1) + 16);
              sprintf($$, "%s.pop_back()", $1);  
          }
        | VARIABLE RIGHT_ARROW LEFT_SQUARE VARIABLE LEFT_SQUARE expression RIGHT_SQUARE RIGHT_SQUARE
          {
              $$ = (char*) malloc(2*strlen($1) + strlen($4) + strlen($6) + 16);
              sprintf($$, "%s[%s] = %s.back();\n%s.pop_back();", $4, $6, $1, $1);
          }
        ;

pop_front: LEFT_SQUARE RIGHT_SQUARE LEFT_ARROW VARIABLE
           {
               $$ = (char*) malloc(2*strlen($4) + 16);
               sprintf($$, "%s.erase(%s.begin())", $4, $4);
           }
         ;

cond_stat: LESS_THAN predicate QUESTION_MARK func_stat_list GREATER_THAN
           {
               $$ = (char*) malloc(strlen($2) + strlen($4) + 16);
               sprintf($$, "if (%s)\n{%s\n}", $2, $4); 
           }
         | LESS_THAN predicate QUESTION_MARK func_stat_list else_if GREATER_THAN
           {
               $$ = (char*) malloc(strlen($2) + strlen($4) + strlen($5) + 16);
               sprintf($$, "if (%s)\n{%s\n} \n%s", $2, $4, $5); 
           } 
         | LESS_THAN predicate QUESTION_MARK func_stat_list else_if ELSE COLON func_stat_list GREATER_THAN
           {
               $$ = (char*) malloc(strlen($2) + strlen($4) + strlen($5) + strlen($8)  + 16);
               sprintf($$, "if (%s)\n{%s\n} \n%s\nelse\n{%s\n}", $2, $4, $5, $8);
           } 
         | LESS_THAN predicate QUESTION_MARK func_stat_list ELSE COLON func_stat_list GREATER_THAN
           {
               $$ = (char*) malloc(strlen($2) + strlen($4) + strlen($7) + 16);
               sprintf($$, "if (%s)\n{%s\n} \nelse\n{%s\n}", $2, $4, $7);
           } 
         ;

else_if: predicate QUESTION_MARK func_stat_list else_if
         {
             $$ = (char*) malloc(strlen($1) + strlen($3) + strlen($4) + 16);
             sprintf($$, "else if (%s)\n{%s\n}\n%s", $1, $3, $4); 
         } 
       | predicate QUESTION_MARK func_stat_list
         {
             $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
             sprintf($$, "else if (%s)\n{%s\n}", $1, $3); 
         } 
       ;

predicate: expression OR expression
           {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s || %s", $1, $3);
           }
         | expression AND expression
           {
                $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
                sprintf($$, "%s && %s", $1, $3);
           }
         | NOT predicate
           {
               $$ = (char*) malloc(strlen($2) + 16);
               sprintf($$, "!%s", $2);
           }
         | LEFT_PAREN predicate RIGHT_PAREN
           {
               $$ = (char*) malloc(strlen($2) + 16);
               sprintf($$, "(%s)", $2);
           }
         | expression LESS_THAN expression
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s < %s", $1, $3);
           }
         | expression GREATER_THAN expression
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s > %s", $1, $3);
           }
         | expression LESS_THAN_EQUAL expression
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s <= %s", $1, $3);
           }
         | expression GREATER_THAN_EQUAL expression
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s >= %s", $1, $3);
           }
         | expression NOT_EQUAL expression
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s != %s", $1, $3);
           }
         | predicate OR predicate
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s || %s", $1, $3);
           }
         | predicate AND predicate
           {
               $$ = (char*) malloc(strlen($1) + strlen($3) + 16);
               sprintf($$, "%s && %s", $1, $3);
           }
         ;

loop_stat: LOOP LEFT_PAREN init SEMI_COLON predicate SEMI_COLON update RIGHT_PAREN COLON LESS_THAN func_stat_list GREATER_THAN
           {
               $$ = (char*) malloc(strlen($3) + strlen($5) + strlen($7) + strlen($11) + 16);
               sprintf($$, "for (%s; %s; %s)\n{ \n%s\n}", $3, $5, $7, $11);
           }
         | LOOP LEFT_PAREN init SEMI_COLON predicate SEMI_COLON update RIGHT_PAREN COLON LESS_THAN func_stat_list GREATER_THAN FINALLY COLON LESS_THAN stat_list GREATER_THAN
		   {
		       $$ = (char*) malloc(strlen($3) + 2*strlen($5) + strlen($7) + strlen($11) + strlen($15) + 128);
			   sprintf($$, "for (%s; %s;)\n{ \n%s\n%s;\nif (!(%s))\n{\n%s\n}\n}", $3, $5, $11, $7, $5, $16);
		   }

init: var_declaration { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
    | var_list_assign { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
    |                 { $$ = (char*) malloc(2); sprintf($$, " ");} 
    ;

update: var_list_assign { $$ = (char*) malloc(strlen($1) + 16); sprintf($$, "%s", $1); }
      |                 { $$ = (char*) malloc(2); sprintf($$, " ");}
      ;

print_stat: PRINT LEFT_PAREN expression RIGHT_PAREN
            {
                $$ = (char*) malloc(strlen($3) + 32);
                sprintf($$, "cout << %s << endl", $3);
            }
%%

int main(int argc, char **argv) {

  if (argc < 2) {
      printf("Enter input file name in command line\n");
      return 1;
  }

  FILE *file = fopen(argv[1], "r"); 

  if (!file)
  {
      printf("File does not exist\n");
      return 1;
  }

system("mkdir -p test/output test/tokens test/parsed");

    char name[100];
    if (argv[1][10] != '/') {
        printf("Input file format should be : test/input/<file_name>.txt\n");
        return 1;
    }

    int i = 0;
    while (argv[1][i+11] != '.')
    {
      name[i] = argv[1][i+11];
      i++;
    }
    name[i] = '\0';

    char output_file[256], lexer_log_file[256], parser_log_file[256];
    snprintf(output_file, sizeof(output_file), "test/output/%s.cpp", name);
    snprintf(lexer_log_file, sizeof(lexer_log_file), "test/tokens/%s_tokens.txt", name);
    snprintf(parser_log_file, sizeof(parser_log_file), "test/parsed/%s_parsed.txt", name);


  out_file = fopen(output_file, "w");
	lexer_log = fopen(lexer_log_file, "w");
	parser_log = fopen(parser_log_file, "w");

  yyin = file;  // Redirect Flex to read from the input file
  yyparse(); // Call the parser

  fclose(file); // Close the file when done
  fclose(out_file);
	fclose(lexer_log);
	fclose(parser_log);

    return 0;
}
