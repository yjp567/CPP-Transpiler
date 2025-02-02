TEST_DIR = test
OUTPUT_DIR = $(TEST_DIR)/output
TOKENS_DIR = $(TEST_DIR)/tokens
PARSED_DIR = $(TEST_DIR)/parsed

all:
	lex lexer.l
	yacc -d parser.y
	gcc -o parser.o y.tab.c

run:
	./parser.o $(TEST_DIR)/input/t1.txt
	./parser.o $(TEST_DIR)/input/t2.txt
	./parser.o $(TEST_DIR)/input/t3.txt
	./parser.o $(TEST_DIR)/input/t4.txt
	./parser.o $(TEST_DIR)/input/t5.txt

clean:
	rm -f parser.o y.tab.* lex.yy.c
	rm -rf $(OUTPUT_DIR) $(TOKENS_DIR) $(PARSED_DIR)