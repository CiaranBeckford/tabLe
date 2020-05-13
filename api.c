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

double mean( double one)
{
	double avg = one / 2.0;
	return avg;
} 

double mean( double * array ){
	int size = sizeof array / sizeof *array;
	double sum = 0;
	for(int i = 0; i < size; i++){
		sum = sum + array[i];
	}
	double avg = sum / size.f;
	return avg;
}

double stdev( double * array ){
	double dev = variance(array);
	return sqrt(dev);
}

double variance(double * array){
	double avg = mean(array);
	int size = sizeof array / sizeof *array;
	double sum = 0;
	for(int i = 0; i < size; i++){
		sum = sum + pow((avg - array[i]), 2);
	}
	double var = sum / size.f;
	return var;
}

double max(double * array){
	double max = array[0];
	for(int i = 0; i < size; i++){
		if (array[i] > max){
			max = array[i];
		}
	}
	return max;
}

double min(double * array){
	double min = array[0];
	for(int i = 0; i < size; i++){
		if (array[i] < min){
			min = array[i];
		}
	}
	return min;
}
