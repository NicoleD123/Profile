/* COMP 211 Homework 4:  Functions.
 *
 * Question2
 *
 * Nicole Deng
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

/*Function to compute the checksum as per the provided rules*/
int checksum(int accnum) {
    int sum = 0, total = 0, count = 0, firstdig, seconddig;
    
    while(accnum > 0) {
        int digit = accnum % 10; //get the temporal last digit
        sum += digit;
        total += sum;
        accnum = accnum/10;
        count++;
    }
    
    // If less than three digits, return an error code
    if (count < 3) {
    return -1;
    }
    
    firstdig = sum % 10;
    seconddig = total % 10;
    return firstdig * 10 + seconddig; // Return two-digit checksum
}

/* Function to validate the account number */
int is_valid(int accnum) {
    int lasttwodig = accnum%100;
    int accountnum = accnum-lasttwodig;

    return lasttwodig == checksum(accountnum);
}

/*Function to generate a new 6 digits account number including the checksum*/
int generate(void) {
    srand48((long int)time(NULL));//set seed
    int count=0;
    int sum=0;
    int digit;

    while (count <6){
        if (count==0){
            digit = (lrand48() % 9) + 1;
        }
        else{
            digit = lrand48() % 10;
        }
        //printf("%d",digit);//for testing purposes
        
        sum = sum*10+digit;
        count++;
    }
    int accnum =sum*100+checksum(sum);

    return accnum;
    }

int main() {
    char response;
    int accnum, generated;

    printf("(C)ompute, (V)alidate, or (G)enerate? "); //promote user to ask which action they'd like to take
    scanf(" %c", &response); 

    if (response == 'C' || response == 'c') { //just in case 
        printf("Please an account number prefix: ");
        scanf("%d", &accnum); // Prompt the input from users
        int check = checksum(accnum);
        
        if (check != -1) {
            printf("Checksum = %d.\n", check);
        } else {
            printf("Error: The account number prefix should have at least three digits.\n");
        }
    } 
    else if (response == 'V' || response == 'v') {
        printf("Enter an account number: ");
        scanf("%d", &accnum); // Prompt the input from users

        if (is_valid(accnum)==true){
            printf("%d is a valid account number.\n",accnum);
        }
        else{
            printf("%d is not a valid account number.\n",accnum);
        }
    } 
    else if (response == 'G' || response == 'g') {
            generated = generate();
            printf("Generated account number: %d\n", generated);
    } 
    else {
        printf("Invalid response.\n");
    }
    return 0;
}