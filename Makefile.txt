CC = bin/sslittle-na-sstrix-gcc
CFLAGS = -g -O

TESTS_DIR = ./mytests

all: branch_tests caching_tests

branch_tests: $(TESTS_DIR)/bpred_corr_branch.o

caching_tests: $(TESTS_DIR)/caching_row_major.o $(TESTS_DIR)/caching_col_major.o

$(TESTS_DIR)/bpred_corr_branch.o: $(TESTS_DIR)/bpred_corr_branch.c
	$(CC) $(CFLAGS) -o $@ $<

$(TESTS_DIR)/caching_row_major.o: $(TESTS_DIR)/caching_row_major.c
	$(CC) $(CFLAGS) -o $@ $<

$(TESTS_DIR)/caching_col_major.o: $(TESTS_DIR)/caching_col_major.c
	$(CC) $(CFLAGS) -o $@ $<

clean: 
	rm -f $(TESTS_DIR)/*.o
