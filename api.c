/*
    C API
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include <stdarg.h>
#include "api.h"

/*https://www.holbertonschool.com/coding-resource-strcat-in-c */
char * string_concat( char * string_1, char * string_2 )
{

    char * new_string = (char *) malloc( strlen(string_1) + strlen(string_2) + 1 );
    strcpy(new_string, string_1);
    strcat(new_string, string_2);

    return new_string;
}

/*list implemented in reference to IRIs project 2018*/
static inline void init_list(struct list_head *head)
{
    head->length = 0;
    head->size = 0;
    head->data.i = NULL;
}

int list_resize(struct list_head *head, int newsize, int unit)
{
    int new_allocated;

    new_allocated = (newsize >> 3) + (newsize < 9 ? 3 : 6);
    if (new_allocated * unit > SIZE_MAX - newsize * unit) {
        errno = -ENOMEM;
        return errno;
    } else
        new_allocated += newsize;

    head->data.i = realloc(head->data.i, new_allocated * unit);

    if (head->data.i == NULL)
        return errno;

    head->size = new_allocated;
    return 0;
}

struct list_head *__new_list()
{
    struct list_head *head;

    head = malloc(sizeof(struct list_head));
    init_list(head);

    if (head == NULL)
        return NULL;


    return head;
}

int __append1(struct list_head **head, int unit)
{
    int err = 0;

    if (*head == NULL)
        *head = __new_list();

    if (*head == NULL)
        return errno;

    if ((*head)->size < (*head)->length + 1)
        err = list_resize(*head, (*head)->length + 1, unit);

    return err;
}

struct list_head *append_int(struct list_head *head, int num, ...)
{
    int err, i, value;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, int);
        err = __append1(&head, sizeof(int));
        if (err)
            perror("list error: ");

        memcpy(&(head->data.i[head->length]),
                                 &value, sizeof(int));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct list_head *append_double(struct list_head *head, int num, ...)
{
    int err, i;
    double value;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, double);
        err = __append1(&head, sizeof(double));
        if (err)
            perror("list error: ");

        memcpy(&(head->data.f[head->length]),
                                 &value, sizeof(double));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct list_head *append_char(struct list_head *head, int num, ...)
{
    int err, i;
    char value;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, int);
        err = __append1(&head, sizeof(char));
        if (err)
            perror("list error: ");

        memcpy(&(head->data.c[head->length]),
                                 &value, sizeof(char));
        head->length += 1;
    }
    va_end(valist);

    return head;
}


double mean(struct list_head *head){
  int size = (head->length);
	double sum = 0;
	for(int i = 0; i < size; i++){
		sum = sum + head->data.f[i];
	}
	double avg = sum / (double) size;
	return avg;
}

double variance(struct list_head *head){
	double avg = mean(head);
	int size = (head->length);
	double sum = 0;
	for(int i = 0; i < size; i++){
    double exp = (avg - head->data.f[i])*(avg - head->data.f[i]);
    sum = sum + exp;
	}
	double var = sum / (double) size;
	return var;
}
double root(double n){
  double lo = 0, hi = n, mid;
  for(int i = 0 ; i < 1000 ; i++){
      mid = (lo+hi)/2;
      if(mid*mid == n) return mid;
      if(mid*mid > n) hi = mid;
      else lo = mid;
  }
  return mid;
}
double stdev(struct list_head *head){
	double dev = variance(head);
  double exp = root(dev);
  return exp;
}



double max(struct list_head *head){
  int size = (head->length);
	double max = head->data.f[0];
	for(int i = 0; i < size; i++){
		if (head->data.f[i] > max){
			max = head->data.f[i];
		}
	}
	return max;
}

double min(struct list_head *head){
  int size = (head->length);
	double min = head->data.f[0];
	for(int i = 0; i < size; i++){
		if (head->data.f[i] < min){
			min = head->data.f[i];
		}
	}
	return min;
}
