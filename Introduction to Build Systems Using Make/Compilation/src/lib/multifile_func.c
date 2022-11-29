#include <stdio.h>
#include <time.h>
#include "multifile_func.h"

void say_hello(void)
{
	printf("Hello, human. How are you today?\n");
}

void print_the_time(void)
{
	time_t current_time;
	time(&current_time);

	printf("Right now it is: %s", ctime(&current_time));
}
