// C and C++ Q&A
const Map<String, String> qACAndCpp = {
  // C++
  "In C++, every program must have one special function named _ _, which serves as the entry point of the program.":
      "MAIN",
  "In C++, to include standard library headers like iostream or vector, we use the directive #_ _ <header_name>.":
      "INCLUDE",
  "In C++, the operator _ _ is used to allocate memory dynamically on the heap, while the operator `delete` is used to free that memory.":
      "NEW",
  "In C++, the operator `new` is used to allocate memory dynamically on the heap, while the operator _ _ is used to free that memory.":
      "DELETE",
  "In C++, a _ _ is a user-defined data type that can contain both data members (variables) and member functions (methods).":
      "CLASS",
  "In C++, to make a class inherit from another class, we use the syntax class Derived : _ _ Base.":
      "PUBLIC",
  "In C++, if we want to prevent a base class function from being overridden in derived classes, we can declare it with the keyword _ _.":
      "FINAL",
  "In C++, to handle exceptions, we wrap code in a _ _ block, catch the exception with a catch block.":
      "TRY",
  "In C++, a function declared with the keyword _ _ inside a base class can be overridden by derived classes to achieve runtime polymorphism.":
      "VIRTUAL",
  "In C++, to overload operators, we define a special member function using the keyword _ _ followed by the operator symbol.":
      "OPERATOR",
  "In C++, _ _ functions are defined inside a class and give the compiler a hint to expand the function’s code inline for efficiency.":
      "INLINE",
  "In C++, a template allows writing generic code. The keyword _ _ is used before defining a template class or function.":
      "TEMPLATE",
  "In C++, to ensure a pointer does not point to any object, we assign it the value _ _, which represents an invalid or empty pointer.":
      "nullptr",
  "In C++, a _ _ is similar to a class, but its members are public by default instead of private.":
      "STRUCT",
  "In C++, instead of raw pointers, we use _ _ pointers (like unique_ptr or shared_ptr) to manage memory safely and avoid leaks.":
      "SMART",

  // C
  "In C, every program must define the function named _ _, which serves as the entry point of the program.":
      "MAIN",
  "In C, to include headers like stdio.h or stdlib.h, we use the directive #_ _ <header_name>.":
      "INCLUDE",
  "In C, to print formatted output to the screen, we call the function _ _.":
      "PRINTF",
  "In C, to read formatted input from the keyboard, we call the function _ _.":
      "SCANF",
  "In C, to allocate dynamic memory on the heap, we use the function _ _.":
      "MALLOC",
  "In C, to free memory previously allocated on the heap, we use the function _ _.":
      "FREE",
  "In C, to allocate zero-initialized memory for an array, we use the function _ _.":
      "CALLOC",
  "In C, to resize a previously allocated memory block, we use the function _ _.":
      "REALLOC",
  "In C, the keyword _ _ declares a variable whose value cannot be modified.":
      "CONST",
  "In C, the storage-class specifier _ _ restricts the linkage of a file-scope symbol to the current translation unit.":
      "STATIC",
  "In C, the storage-class specifier _ _ declares a symbol that is defined in another translation unit.":
      "EXTERN",
  "In C, we create a type alias using the keyword _ _.": "TYPEDEF",
  "In C, we group related fields into a record-like aggregate using the keyword _ _.":
      "STRUCT",
  "In C, we define an enumeration using the keyword _ _.": "ENUM",
  "In C, the operator _ _ yields the size in bytes of a type or expression.":
      "SIZEOF",
  "In C, the jump statement _ _ transfers control to a labeled statement in the same function.":
      "GOTO",
  "In C, to select a member through a pointer (p->field), we use the _ _ operator.":
      "ARROW",
  "In C, the conditional operator ? : is commonly called the _ _ operator.":
      "TERNARY",
  "In C, conditional compilation can be done with the directive #_ _ to check whether a macro is defined.":
      "IFDEF",
  "In C, to prevent multiple inclusion of a header, we typically guard it with #_ _ and #endif.":
      "IFNDEF",
  "In C, the null pointer constant is written as _ _.": "NULL",
  "In C, the macro name that terminates the program with a status code is _ _.":
      "EXIT",
  "In C, standard strings are arrays of elements of type _ _.": "CHAR",
  "In C, to indicate that a function takes no parameters, we write the parameter list as _ _.":
      "VOID",
  "In C, the loop that tests the condition after the body uses the keywords _ _ and while.":
      "DO",
  "In C, inside a switch statement, labels are introduced with the keyword _ _.":
      "CASE",
  "In C, to skip the current iteration of a loop and continue with the next, we use _ _.":
      "CONTINUE",
  "In C, to exit a loop or a switch immediately, we use the statement _ _.":
      "BREAK",
};
