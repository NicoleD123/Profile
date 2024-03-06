
/* COMP 211 Homework 3:  C basics.
 *
 * Hide and seek  code.
 *
 * Nicole Deng
 */

/* Do not delete any of these include directives (though you may add others if
 * you need to).  stdlib.h is needed for the random number generation functions
 * and time.h is needed to get the current time.
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* You can change "8" if you want to play around with different world sizes (we
 * will when we test your code), but do not change anything else here!
 */
#ifndef WORLD_SIZE
#define WORLD_SIZE 8
#endif


void move(int *x, int *y) {
    int direction = lrand48() % 4; // 0=North, 1=East, 2=South, 3=West
    //printf("%d\n", direction);
    switch (direction) {
        case 0: // if heading to North
            if (*y > 0) (*y)--;
            else {
                (*y)++;
            }
            break;
        case 1: // if heading to East
            if (*x < WORLD_SIZE - 1) (*x)++;
            else (*x)--;
            break;
        case 2: // if heading to South
            if (*y < WORLD_SIZE - 1) (*y)++;
            else (*y)--;
            break;
        case 3: // if heading to West
            if (*x > 0) (*x)--;
            else (*x)++;
            break;
    }
}

int main() {

    /* This instruction "seeds the random number generator with the current
     * time."  The random number generator we are using produces numbers based
     * on a "seed value," which defaults to 0.  If you use the same seed value
     * each time you run the program, you get the same sequence of random
     * numbers.  By making the seed value the current time (which is what is
     * returned by `time(NULL)`), then you will get different random numbers
     * each time you run the program.
     */

    int simulations, steps;
    printf("Enter the number of simulation to run: ");
    scanf("%d", &simulations);
    srand48(time(NULL));
    
    while (simulations--) {
        int rabbitX = WORLD_SIZE / 2, rabbitY = WORLD_SIZE / 2;
        int foxX = rand() % WORLD_SIZE, foxY = rand() % WORLD_SIZE; //the location of Fox is random
        int foodX = rand() % WORLD_SIZE, foodY = rand() % WORLD_SIZE; //the location of Food is random
        steps = 0; //count the steps
        int foodFound = 0; //

        while (1) {
            move(&rabbitX, &rabbitY); //move of rabbit
            move(&foxX, &foxY); //move of fox
            steps++; 

            // When food is found, set the var to 1
            if (rabbitX == foodX && rabbitY == foodY) {
                foodFound = 1;
            }

            // When rabbit reaches home
            if (rabbitX == WORLD_SIZE / 2 && rabbitY == WORLD_SIZE / 2) {
                if (foodFound) {
                printf("Rabbit makes it home in %d steps and is fed!\n", steps);
                }

                else {
                    printf("Rabbit makes it home in %d steps but is hungry!\n", steps);
                }
                break;
            }

            // Fox catches the rabbit
            if (rabbitX == foxX && rabbitY == foxY) {
                printf("Fox catches the rabbit in %d steps!\n", steps);
                break;
            }
        }
    }


    return 0 ;
}
