// JavaScript and TypeScript Q&A
const Map<String, String> qAJavaScriptTypeScript = {
  // JavaScript
  "In JavaScript, declare a block-scoped variable that can be reassigned using the keyword _ _.":
      "LET",
  "In JavaScript, declare a block-scoped constant that cannot be reassigned with the keyword _ _.":
      "CONST",
  "In JavaScript, a function bundled with its lexical environment (captured variables) is called a _ _.":
      "CLOSURE",
  "In JavaScript, the compile-time behavior where declarations are moved to the top of their scope is called _ _.":
      "HOISTING",
  "In JavaScript, an object representing an eventual async result with states pending/fulfilled/rejected is a _ _.":
      "PROMISE",
  "In modern JavaScript, inside an async function, pause until a Promise settles using _ _.":
      "AWAIT",
  "In modern JavaScript, mark a function that implicitly returns a Promise with the keyword _ _.":
      "ASYNC",
  "In JavaScript, the ... operator that expands iterables or object properties is called _ _.":
      "SPREAD",
  "In JavaScript, the ... parameter that packs remaining arguments into an array is the _ _ parameter.":
      "REST",
  "In JavaScript, the single-threaded scheduling mechanism that processes tasks and microtasks is the _ _.":
      "EVENTLOOP",
  "In JavaScript, the structure that tracks currently executing frames is the _ _.":
      "CALLSTACK",
  "In JavaScript, jobs created by resolving Promises that run before the next macrotask are _ _.":
      "MICROTASK",
  "In JavaScript, the === operator performs _ _ equality (no type coercion).":
      "STRICTEQ",
  "In JavaScript, the module system that uses require(...) and module.exports is _ _.":
      "COMMONJS",
  "In JavaScript, the standardized module syntax that uses import and export is _ _.":
      "ESMODULE",
  "In JavaScript, automatic type conversion during comparisons or arithmetic is called _ _.":
      "COERCION",
  "In JavaScript, values that evaluate to false in conditionals (false, 0, '', null, undefined, NaN) are _ _ values.":
      "FALSY",
  "In JavaScript, values that evaluate to true in conditionals (non-falsy values) are _ _ values.":
      "TRUTHY",
  "In JavaScript, the primitive for unique identifiers that never collide is _ _.":
      "SYMBOL",
  "In JavaScript, build a new array by transforming each element with a callback using Array._ _(...).":
      "MAP",
  "In JavaScript, keep only elements where a callback returns true using Array._ _(...).":
      "FILTER",
  "In JavaScript, copy properties into a target object with Object._ _(target, ...sources).":
      "ASSIGN",
  "In JavaScript, extract fields from objects or items from arrays into variables using _ _ syntax.":
      "DESTRUCT",
  "In JavaScript, an Immediately Invoked Function Expression is abbreviated _ _.":
      "IIFE",
  "In JavaScript, raise an exception so it can be caught by the nearest handler using _ _.":
      "THROW",
  "In JavaScript, enable stricter semantics by placing the directive 'use _ _' at the top of a file or function.":
      "STRICT",
  "In JavaScript, a key-value store that holds weak references to object keys is a _ _.":
      "WEAKMAP",
  "In JavaScript, a collection that holds weak references to objects without preventing GC is a _ _.":
      "WEAKSET",
  "In JavaScript, convert a value to JSON text with JSON._ _(value).":
      "STRINGIFY",
  "In JavaScript, turn JSON text into a value with JSON._ _(text).": "PARSE",
  "In JavaScript, create an array from an iterable or array-like object using Array._ _(...).":
      "FROM",
  "In JavaScript, the popular server-side runtime built on Chrome's V8 engine is _ _.":
      "NODEJS",

  // TypeScript
  "In TypeScript, assign a name to a type alias using the keyword _ _ (e.g., type ID = string).":
      "TYPE",
  "In TypeScript, declare a shape-only contract of properties and methods with _ _.":
      "INTERFACE",
  "In TypeScript, reuse code across many types by parameterizing with _ _.":
      "GENERICS",
  "In TypeScript, a type for values that never occur (e.g., throw or infinite loop) is _ _.":
      "NEVER",
  "In TypeScript, a top type that disables checking and permits any operation is _ _.":
      "ANY",
  "In TypeScript, a safer top type that must be narrowed before use is _ _.":
      "UNKNOWN",
  "In TypeScript, refine a union by checking typeof, in, or discriminant fields; this is type _ _.":
      "NARROWING",
  "In TypeScript, define a fixed set of named constants using the keyword _ _.":
      "ENUM",
  "In TypeScript, combine alternatives like A | B with a _ _ type.": "UNION",
  "In TypeScript, describe an array with fixed positions and element types using a _ _ type.":
      "TUPLE",
  "In TypeScript, obtain the property names of a type using the operator _ _.":
      "KEYOF",
  "In TypeScript, make a property immutable by adding the modifier _ _.":
      "READONLY",
  "In TypeScript, give an existing type a new name by creating a type _ _.":
      "ALIAS",
  "In TypeScript, turn all properties of T into optional ones with the utility type _ _<T>.":
      "PARTIAL",
  "In TypeScript, create a type with keys K mapping to values T using _ _<K, T>.":
      "RECORD",
  "In TypeScript, build a subtype with only keys K from T using _ _<T, K>.":
      "PICK",
  "In TypeScript, build a subtype that excludes keys K from T using _ _<T, K>.":
      "OMIT",
  "In TypeScript, extract a type from a generic constraint within a conditional type using _ _.":
      "INFER",
  "In TypeScript, write functions that act as type guards by returning _ _ in the signature (e.g., asserts x is Foo).":
      "ASSERTS",
  "In TypeScript, restrict a variable to exact primitive values (e.g., 'on' | 'off') using _ _ types.":
      "LITERAL",
  "In TypeScript, prevent literal widening and preserve exact literals with the assertion _ _.":
      "ASCONST",
  "In TypeScript, describe callable or constructable shapes with a function _ _ type.":
      "SIGNATURE",
  "In TypeScript, enable the most rigorous checks by turning on the compiler option _ _.":
      "STRICT",
  "In TypeScript, compile the project from the command line using _ _.": "TSC",
  "In TypeScript, annotate classes and members with experimental @ metadata using a _ _.":
      "DECORATOR",
  "In TypeScript, types that transform property sets (with modifiers or remapped keys) are _ _ types.":
      "MAPPED",
  "In TypeScript, verify that an expression conforms to a target type without changing its type using _ _.":
      "SATISFIES",
};
