/* COMP 211 Homework 4:  Functions.
 *
 * Question 1
 *
 * Nicole Deng
 */

#include <stdio.h>
#include <math.h>

/* fact211(n) = n!
 * Computes the factorial of a non-negative integer n.
 * n! is the product of all positive integers less than or equal to n.
 * For n < 0, the function returns 0.
 */

unsigned long fact211(int n) {
    if (n >= 0) {
        unsigned long factorial = 1;
        for(int i = 1; i <= n; ++i) {
            factorial = factorial*i;
        }
        //printf("%lu\n",factorial);

        return factorial;
    }
    return 0;
}

/* pow211(x, n) = x^n
 * Computes the power of x raised to a non-negative integer n.
 * The function returns the product of x multiplied by itself n times.
 */
double pow211(double x, int n){
    double pow=1.0;
    for(int i = 0; i < n; i++) {
        pow *= x;
    }
    return pow;
}

/* abs211(x) = |x|
 * Returns the absolute value of x (x can be any real number).
 * The absolute value |x| is the non-negative value of x without regard to its sign.
 */
double abs211 ( double x){
    if (x>=0){
    //nothing needs to be done for positive num or zero
    }
    else{
        x=-x;
        printf("%lf",x);
    }
    return x;
}

/*approx_cos return an approximation of the cosine of x using the 
Taylor series expansion.*/

/* approx_cos(x, eps) ≈ cos(x)
 * Returns an approximation of the cosine of x using the Taylor series expansion.
 * The approximation is calculated up to the smallest term with absolute value greater or equal to eps.
 */
double approx_cos ( double x , double eps ){
    double sum, term;
    sum=1.0;
    int k=1;

    //calculate initial term
    term = (pow211(x,2*k))/fact211(2*k);
    //printf("term value: %lf\n",term);
    
    while( abs211(term) >= eps){
    
    term = (pow211(x,2*k))/fact211(2*k);
    //printf("term value: %lf\n",term);
        if (k % 2 == 1) { //for the odd
            sum -= term;
        } else {
            sum += term; //for the even
        }
        k++;
    }
    //printf("sum: %lf\n",sum);
    return sum;
}

/* cos211(x) = cos(x)
 * Returns the cosine of x normalized to the range [0, 2π) using the Taylor series expansion.
 * The function  normalizes x to be within the range [0, 2π), then computes cos(x) with a predefined precision of 10^-8.
 */
double cos211(double x) {
    // Normalize x to be within [0, 2*π]
    while (x > 2 * M_PI) {
        x -= 2 * M_PI;
    }
    while (x < 0) {
        x += 2 * M_PI;
    }
    if (x >= M_PI) {
        x = 2 * M_PI - x; //  x around π to be in [0, π)
    }
    return approx_cos(x, 1e-8); // Using the eps value of 10^-8
}

/*
int main() {
    approx_cos(-.7854, 1e-8);
    printf("%lf", approx_cos(-0.7854, 1e-8));
}
*/

int main() {
    double x;
    printf("Please enter a value for x (in radians): ");
    scanf("%lf", &x); // Prompt the input from users

    printf("cos211(%lf) = %lf\n", x, cos211(x)); 
    
    return 0;
}

