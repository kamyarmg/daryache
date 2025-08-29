// C# Q&A
const Map<String, String> qACSharp = {
  "In C#, every executable application begins at the entry-point method named _ _ (typically declared as static void Main(string[] args)).":
      "MAIN",
  "In C#, to make types from a namespace available without fully qualifying them, add a _ _ directive at the top of the file (e.g., for the System namespace).":
      "USING",
  "In C#, group related types and avoid name collisions by declaring a _ _ block.":
      "NAMESPACE",
  "In C#, define a reference type (class with reference semantics) using the keyword _ _.":
      "CLASS",
  "In C#, define a value type (value semantics; often used for small data aggregates) with the keyword _ _.":
      "STRUCT",
  "In C#, define a contract of members without implementation using _ _.":
      "INTERFACE",
  "In C#, define a set of named integral constants with the keyword _ _.":
      "ENUM",
  "In C#, define an immutable, value-based type with built-in value equality and with-expressions using the keyword _ _.":
      "RECORD",
  "In C#, write a line of text to standard output by calling Console._ _(...).":
      "WRITELINE",
  "In C#, read a line of input from standard input by calling Console._ _() (returns a string).":
      "READLINE",
  "In C#, the built-in type keyword for text is _ _.": "STRING",
  "In C#, the built-in type keyword for 32-bit signed integers is _ _.": "INT",
  "In C#, the built-in type keyword for logical true/false values is _ _.":
      "BOOL",
  "In C#, declare compile-time constants with the keyword _ _.": "CONST",
  "In C#, fields that can only be assigned at declaration or inside a constructor use _ _.":
      "READONLY",
  "In C#, mark a class that cannot be instantiated directly with the keyword _ _.":
      "ABSTRACT",
  "In C#, mark a class that cannot be inherited from with the keyword _ _.":
      "SEALED",
  "In C#, allow a method to be overridden in derived classes with the keyword _ _.":
      "VIRTUAL",
  "In C#, provide a new implementation of a virtual or abstract member with _ _.":
      "OVERRIDE",
  "In C#, hide a base member by introducing a new member with the keyword _ _.":
      "NEW",
  "In C#, handle exceptions with a _ _ block followed by one or more catch blocks and optionally a finally block.":
      "TRY",
  "In C#, ensure deterministic cleanup of IDisposable resources at scope end using the _ _ statement.":
      "USING",
  "In C#, declare an event publisher (observable notifications) with the keyword _ _.":
      "EVENT",
  "In C#, the task-based abstraction for asynchronous operations is _ _.":
      "TASK",
  "In C#, mark a method as asynchronous with the keyword _ _.": "ASYNC",
  "In C#, inside an async method, wait for an asynchronous result with _ _.":
      "AWAIT",
  "In C#, Language Integrated Query (for querying objects, XML, SQL, etc.) is abbreviated _ _.":
      "LINQ",
  "In C#, the operator => is called the _ _ operator and is used in lambda expressions and expression-bodied members.":
      "LAMBDA",
  "In C#, define an extension method by placing the modifier _ _ on the first parameter of a static method in a static class.":
      "THIS",
  "In C#, test type compatibility (and perform pattern matching) with the operator _ _.":
      "IS",
  "In C#, safely cast and get null if the cast fails using the operator _ _.":
      "AS",
  "In C#, the literal that represents no object reference is _ _.": "NULL",
  "In C#, create a verbatim string literal (useful for paths or multi-line text) by prefixing the string with _ _.":
      "AT",
  "In C#, enable string interpolation by prefixing the string with _ _ and embedding expressions in { }.":
      "DOLLAR",
  "In C#, retrieve a symbol's simple name at compile time (avoiding magic strings) with _ _(...).":
      "NAMEOF",
  "In C#, yield values lazily from an iterator method using the keyword _ _ (e.g., yield return).":
      "YIELD",
  "In C#, protect a critical section by acquiring a monitor using the statement _ _.":
      "LOCK",
  "In C#, pass an argument by reference so the callee can modify the caller's variable with the modifier _ _.":
      "REF",
  "In C#, pass an argument by reference that must be assigned by the callee with _ _.":
      "OUT",
  "In C#, pass a read-only reference argument (cannot be modified by the callee) with the modifier _ _.":
      "IN",
  "In C#, declare a parameter array (variadic arguments) using the modifier _ _.":
      "PARAMS",
  "In C#, auto-implemented properties use the accessor _ _ (and set), as in { get; set; }.":
      "GET",
  "In C#, the root base type of all types in .NET is _ _.": "OBJECT",
  "In C#, a generic list type is written as List<_ _> (angle-bracketed type parameter).":
      "T",
};
