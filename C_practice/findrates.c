
#include <stdio.h>

double Pred(char *file_name) {
    FILE* f = fopen(file_name, "r");
    if (f == NULL) {
        printf("Error opening file.\n");
        return -1; // Return an error code if file can't be opened
    }

    double r, K, d, lowp, highp, step, a, initialPreyPop, initialPredPop,P_pred,P_prey;
    int Th, timeSteps;

    // Read the parameters from the file
    fscanf(f, "Prey birth rate: %lf\n", &r);
    fscanf(f, "Prey carrying capacity: %lf\n", &K);
    fscanf(f, "Predator death rate: %lf\n", &d);
    fscanf(f, "Low kill rate: %lf\n", &lowp);
    fscanf(f, "High kill rate: %lf\n", &highp);
    fscanf(f, "Kill step: %lf\n", &step);
    fscanf(f, "Handling time: %d\n", &Th);
    fscanf(f, "Conversion rate: %lf\n", &a);
    fscanf(f, "Initial prey population: %lf\n", &initialPreyPop);
    fscanf(f, "Initial predator population: %lf\n", &initialPredPop);
    fscanf(f, "Time steps: %d\n", &timeSteps);

    int stable;

    // Loop over kill rates
    for (double p = lowp; p <= highp; p += step) {
        P_pred = initialPredPop; // Reset to initial value
        P_prey = initialPreyPop; // Reset to initial value
        stable = 1;

        for (int t = 0; t < timeSteps; t++) {
            double function = (p * P_prey * P_prey) / (1 + p * Th * P_prey * P_prey);
            
            double next_P_pred = P_pred + a * function * P_pred - d * P_pred;
            

            if (next_P_pred < 1.0) {
                next_P_pred = 0.0;
            }
            
            double next_P_prey = P_prey + r * P_prey * (1 - P_prey / K) - function*P_pred;
            
            if (next_P_prey < 1.0) {
                next_P_prey = 0.0;
            }

            P_pred = next_P_pred;
            P_prey = next_P_prey;
            
            if (P_prey == 0.0 ||P_pred == 0.0) {
                stable = 0;
                break;
            }
        }
        if (stable==1)
            printf("Kill rate %lf is stable.\n", p);
        else
            printf("Kill rate %lf is unstable.\n", p);
    }
    return 0.0;
}

int main(void) {
    Pred("params.txt");
    return 0;
}
