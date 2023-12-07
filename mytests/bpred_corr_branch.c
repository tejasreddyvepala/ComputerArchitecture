#include <stdio.h>
#include <stdlib.h>

#define myrand() (double) rand()/RAND_MAX
#define SEED 5
#define PROB 0.3

int main()
{       
        int i, a;
        srand(SEED);

	printf("Running test %s...\n", __FILE__);

        a = 0;
        for(i = 0; i < 10000; i++) {
                if(myrand() < PROB) {
                        a = 1; 
                }
                        
                if(a) {
                        a = 0;
                }
        }

        return 0;
}