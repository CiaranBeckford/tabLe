# tabLe
## Ciaran Beckford, Yalon Gordon, Joshua Hazlett, Selena Huang

### How to run

```
make
./table.native [file.tabLe]
./a.out
```

### Motivation
tabLe is an imperative programming language with the simplicity of Python-like syntax and the strict typing of Java. With an imperative paradigm, strongly typed system, statically scoped, strict evaluation order and features like Algebraic Data Types. tabLe also includes a built-in math library that makes calling operations intuitive to the user. 

This programming language is oriented towards statisticians who have zero or limited programming experience. This combination of features will help minimize unwanted errors that might arise for someone new to programming. tabLe is a very simple language with high functionality for data dissection. The elegance of the language lies in the simple syntax and ready-made statistical functions. 

### Paradigms and Features
tabLe will be an imperative language, with strongly and statically typed, static scoping, and strict evaluation order semantics. tabLe will feature algebraic data types, and will have a built in library of mathematical and statistics functions in order to streamline usage for new programmers.

### "Hello World" Program
```
~addition~
def int foo <int a, int b> { 
	    int f = a + b;
	    return f;
}
```
### Language in One Slide
This program demonstrates the statistical capabilities of this language. This function dashboard returns a tuple of type `(int, int)` while taking in an `int array`. The function header begins with the `def` keyword, similar to a function definition in Python. However, we want our programmers to immediately know what types are being returned and passed as parameters, so those types must be included. To distinguish between tuples and function parameters, we use `( , )` and `<,>` respectively. 

This program displays a lot of the functionality of the language including type conversion, concatenation, library functions, comments, and the array data structure

```
~ calculate characteristics of a data set ~
def tuple(int, int) dashboard <int array data>
{
    	int mean = mean<data>; ~built in function~
    	int max = max<data>; ~built in function~
    	tuple(int, int) result = (mean, max);
    	return result;
}
int array data = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ];

float mean, float max = dashboard<data>; 

string out = "The mean is: " + string<mean>;
print<out>;

out = "The max is: " + string<max>;
print<out>;

float std = stdev<data>; ~built in function~ 

out = "The standard deviation is: " + string<std>;
print<out>;
```
