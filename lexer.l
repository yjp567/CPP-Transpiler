%{ 
#include <stdio.h>
#include "y.tab.h"
int lineno=1;
FILE *lexer_log;
%}

%%

[0-9]+              {yylval.str = strdup(yytext);fprintf(lexer_log, "%d : Constant : %s\n",lineno, yytext);return INTEGER_CONST;}
([0-9]+\.[0-9]+)	{ yylval.str = strdup(yytext);;fprintf(lexer_log, "%d : Constant : %s\n",lineno, yytext);fflush(lexer_log);return DOUBLE_CONST;};

\[	                {fprintf(lexer_log, "%d : Punctuation : Access Operator : %s\n",lineno, yytext);return LEFT_SQUARE;};
\]	                {fprintf(lexer_log, "%d : Punctuation : Access Operator : %s\n",lineno, yytext);return RIGHT_SQUARE;};
\{	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return LEFT_CURLY;};
\}	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return RIGHT_CURLY;};
\(	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return LEFT_PAREN;};
\)	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return RIGHT_PAREN;};

:	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return COLON;};
;	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return SEMI_COLON;}
,                   {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return COMMA;};

\<=	                {fprintf(lexer_log, "%d : Comparison Operator : %s\n",lineno, yytext);return LESS_THAN_EQUAL;};
\>=	                {fprintf(lexer_log, "%d : Comparison Operator : %s\n",lineno, yytext);return GREATER_THAN_EQUAL;};
\<>	                {fprintf(lexer_log, "%d : Comparison Operator : %s\n",lineno, yytext);return NOT_EQUAL;};
\<	                {fprintf(lexer_log, "%d : Punctuation : Comparison Operator : %s\n",lineno, yytext);return LESS_THAN;}
\>	                {fprintf(lexer_log, "%d : Punctuation : Comparison Operator : %s\n",lineno, yytext);return GREATER_THAN;};
\?	                {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return QUESTION_MARK;};
=                   {fprintf(lexer_log, "%d : Punctuation : %s\n",lineno, yytext);return ASSIGN;};   

set	                {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return SET;};
if	                {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return IF;};
else                {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return ELSE;};
size                {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return SIZE;};
loop                {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return LOOP;};
finally	            {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return FINALLY;};
return	            {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return RETURN;};
func	            {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return FUNC;};
print	            {fprintf(lexer_log, "%d : Reserved Word : %s\n",lineno, yytext);return PRINT;};
void                {fprintf(lexer_log, "%d : Type : %s\n",lineno, yytext);return VOID;};
int	                {fprintf(lexer_log, "%d : Type : %s\n",lineno, yytext);return INTEGER;};
float	            {fprintf(lexer_log, "%d : Type : %s\n",lineno, yytext);return FLOAT;};
small	            {fprintf(lexer_log, "%d : Type : %s\n",lineno, yytext);return SMALL;};
big	                {fprintf(lexer_log, "%d : Type : %s\n",lineno, yytext);return BIG;};

\->	                {fprintf(lexer_log, "%d : Access Operator : %s\n",lineno, yytext);return RIGHT_ARROW;};
\<-	                {fprintf(lexer_log, "%d : Access Operator : %s\n",lineno, yytext);return LEFT_ARROW;};

\+	                {fprintf(lexer_log, "%d : Arithmeatic Operator : %s\n",lineno, yytext);return ADD_OP;};
-	                {fprintf(lexer_log, "%d : Arithmeatic Operator : %s\n",lineno, yytext);return SUB_OP;};
\/	                {fprintf(lexer_log, "%d : Arithmeatic Operator : %s\n",lineno, yytext);return DIV_OP;};
\*	                {fprintf(lexer_log, "%d : Arithmeatic Operator : %s\n",lineno, yytext);return MUL_OP;};
\%                  {fprintf(lexer_log, "%d : Arithmeatic Operator : %s\n",lineno, yytext);return REM_OP;};

\|	                {fprintf(lexer_log, "%d : Bitwise Operator : %s\n",lineno, yytext);return BIT_OR;};
\^	                {fprintf(lexer_log, "%d : Bitwise Operator : %s\n",lineno, yytext);return BIT_XOR;};
&	                {fprintf(lexer_log, "%d : Bitwise Operator : %s\n",lineno, yytext);return BIT_AND;};
~	                {fprintf(lexer_log, "%d : Bitwise Operator : %s\n",lineno, yytext);return BIT_NOT;};
or	                {fprintf(lexer_log, "%d : Logical Operator : %s\n",lineno, yytext);return OR;};
and	                {fprintf(lexer_log, "%d : Logical Operator : %s\n",lineno, yytext);return AND;};
not	                {fprintf(lexer_log, "%d : Logical Operator : %s\n",lineno, yytext);return NOT;};
    
[_a-zA-Z][_a-zA-Z0-9]*	{yylval.str = strdup(yytext); fprintf(lexer_log, "%d : Identifier : %s\n",lineno, yytext);/*fflush(lexer_log);*/return VARIABLE;};

#.*\n               {fprintf(lexer_log, "%d : Single Line Comment : %s",lineno++, yytext);};

\n                  {lineno++;}           
[ \t]               {}

.                   {  printf("Unrecognized character: %s\n", yytext); exit(1); }

%%

int yywrap() { return 1; }