/* COMP 211 Homework 4:  Functions.
 *
 * Specifications.
 *
 * Nicole Deng
 */

#include <math.h>
#include <stdio.h>
#include <stdbool.h>

/**
 * f(x,y,z) = sum of the smallest and largest values among three integers.
 * @param x an integer.
 * @param y an integer.
 * @param z an integer.
 * The function return the sum of the smallest and largest integers among the input parameters.
 */
int f(int x, int y, int z) {
    if (x <= y) {
        if (y <= z) return x + z ;
        else if (x <= z) return x + y ;
        else return z + y ;
    }
    else {
        if (x <= z) return y + z ;
        else if (y <= z) return y + x ;
        else return x + y ;
    }
}

/* 
 * For this problem, it is not acceptable to have as your specification
 *   g(x) = x mod 2 == 0 && x/2 mod 2 == 0 && x/4 mod 2 = 0.
 * Play around with the function and determine what the return value tells you
 * about the argument.
 */

/**
 * bool g(int x, int y, int z) == true   if the first of three integers is a multiple of 8.
 *
 * @param x An integer to be checked for being a multiple of 8.
 * @param y An integer that is not used.
 * @param z An integer that is not used.
 * 
 * bool g(int x, int y, int z) == true if `x` is a multiple of 8.
 * bool g(int x, int y, int z) == false if `x` is a multiple of 8.
 */
bool g(int x, int y, int z) {
    return x % 2 == 0 && x/2 % 2 == 0 && x/4 % 2 == 0 ;
}

/* 
 * Hint:  the parameters are used to describe a circle and a point.  Your
 * specification must say how they do that, and the result must the geometric
 * information that is returned by the function.
 */

/**
 * h(double x0, double y0, double r0, double x1, double y1) == true   if a point is within a given circle.
 *
 * The circle is defined by a center at coordinates (x0, y0) and has a radius of r0.
 * The point in question is defined by its coordinates (x1, y1).
 * The function calculates the distance between the center of the circle
 * and the point, and compares this distance to the radius of the circle.
 *
 * @param x0 The x-coordinate of the circle's center.
 * @param y0 The y-coordinate of the circle's center.
 * @param r0 The radius of the circle.
 * @param x1 The x-coordinate of the point.
 * @param y1 The y-coordinate of the point.
 * @return The function will return true if the point (x1, y1) lies inside the circle
 *         centered at (x0, y0) with radius r0, and return false if the point lies on the circle's
 *         circumference or outside the circle.
 */

bool h(double x0, double y0, double r0, double x1, double y1) {
    /* You may assume that sqrt satisfies the specification
     *   sqrt(x) = √x
     */
    double dx = x1 - x0 ;
    double dy = y1 - y0 ;
    double d = sqrt(dx*dx + dy*dy) ;

    return r0 > d ;
}

int main(void) {

    return 0 ;
}
