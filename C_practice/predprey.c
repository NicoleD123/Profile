
#include <stdio.h>

double Pred(char * file_name){
    //pointer
    FILE* f;
    f = fopen (file_name,"r") ;
    //declare variables
    double r, K, d, p, a, initialPreyPop, initialPredPop;
    int Th, timeSteps;

    //read the parameters form the file
    fscanf(f, "Prey birth rate: %lf\n", &r);\
    fscanf(f, "Prey carrying capacity: %lf\n", &K);
    fscanf(f, "Predator death rate: %lf\n", &d);
    fscanf(f, "Kill rate: %lf\n", &p);
    fscanf(f, "Handling time: %d\n", &Th);
    fscanf(f, "Conversion rate: %lf\n", &a);
    fscanf(f, "Initial prey population: %lf\n", &initialPreyPop);
    fscanf(f, "Initial predator population: %lf\n", &initialPredPop);
    fscanf(f, "Time steps: %d\n", &timeSteps);

    // Print the parameters to the console for verification
    printf("r: %lf, K: %lf, d: %lf, p: %lf, Th: %d, a: %lf\n", r, K, d, p, Th, a);
    printf("Initial prey population: %lf, Initial predator population: %lf, Time steps: %d\n",
           initialPreyPop, initialPredPop, timeSteps);
    
    //declare initial population variables for calculation
    double P_pred = initialPredPop; // initial predator population
    double P_prey = initialPreyPop; // initial prey population
    double function; //f

// for loop 
    for (int t = 0; t < timeSteps; t++) {
        // implement the function
        function = (p * P_prey * P_prey) / (1 + p * Th * P_prey * P_prey);

         // Calculate next time step predator population
        double next_P_pred = P_pred + a * function * P_pred - d * P_pred;

        // Calculate next time step prey population
       double next_P_prey = P_prey + r * P_prey * (1 - P_prey / K) - function * P_pred;

        // Update the populations
        P_pred = next_P_pred;
        P_prey = next_P_prey;

        // Display the final results
        printf("Time step %d: Predators: %lf, Preys: %lf\n", t + 1, P_pred, P_prey);

    }
    return 0.0;
}

int main(void) {
    Pred("params.txt");
    return 0;
    
}