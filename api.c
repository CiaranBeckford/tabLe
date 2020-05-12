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
