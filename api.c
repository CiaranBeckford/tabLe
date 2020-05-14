/*
    C API
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*https://www.holbertonschool.com/coding-resource-strcat-in-c */
char * string_concat( char * string_1, char * string_2 )
{

    char * new_string = (char *) malloc( strlen(string_1) + strlen(string_2) + 1 );
    strcpy(new_string, string_1);
    strcat(new_string, string_2);

    return new_string;
}

/*double mean( double one)
{
	double avg = one / 2.0;
	return avg;
} */

double mean( double * array ){
	int size = *(&array + 1) - array; 
	double sum = 0;
	for(int i = 0; i < size; i++){
		sum = sum + array[i];
	}
	double avg = sum / (double) size;
	return avg;
}

double variance(double * array){
	double avg = mean(array);
	int size = *(&array + 1) - array; 
	double sum = 0;
	for(int i = 0; i < size; i++){
		sum = sum + pow((avg - array[i]), 2);
	}
	double var = sum / (double) size;
	return var;
}

double stdev( double * array ){
	double dev = variance(array);
	return sqrt(dev);
}

double max(double * array){
	int size = *(&array + 1) - array;
	double max = array[0];
	for(int i = 0; i < size; i++){
		if (array[i] > max){
			max = array[i];
		}
	}
	return max;
}

double min(double * array){
	int size = *(&array + 1) - array;
	double min = array[0];
	for(int i = 0; i < size; i++){
		if (array[i] < min){
			min = array[i];
		}
	}
	return min;
}
