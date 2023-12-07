
#include <stdio.h>

#define N 1000
#define M 1000

int main()
{
        int i, j;
        int matrix[N][M] = {0}; 

        printf("Running test %s...\n", __FILE__);

        for(i = 0; i < N; i++) {
                for(j = 0; j < M; j++) {
                        matrix[i][j] = 1;
                }
        }

        return 0;
}