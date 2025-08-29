// Java Q&A
const Map<String, String> qAJava = {
  "In Java, group related classes to avoid name clashes and control visibility with the _ _ declaration at the top of a file.":
      "PACKAGE",
  "In Java, bring types from another package into scope without fully qualifying them using the _ _ statement (for example, java.util.List).":
      "IMPORT",
  "In Java, declare a field or variable that cannot be reassigned by marking it _ _.":
      "FINAL",
  "In Java, share a member across all instances of a class by declaring it _ _.":
      "STATIC",
  "In Java, define a class that cannot be instantiated directly (and may contain abstract methods) by marking it _ _.":
      "ABSTRACT",
  "In Java, specify single inheritance for a class using the keyword _ _ BaseClass.":
      "EXTENDS",
  "In Java, declare a contract of methods without implementation using the keyword _ _.":
      "INTERFACE",
  "In Java, limit member access to the same class only with the modifier _ _.":
      "PRIVATE",
  "In Java, allow access within the package and from subclasses by marking a member _ _.":
      "PROTECTED",
  "In Java, ensure cleanup code always runs after try/catch by placing it in a _ _ block.":
      "FINALLY",
  "In Java, annotate a method that intentionally replaces a superclass implementation with @ _ _.":
      "OVERRIDE",
  "In Java, declare a concise immutable data carrier type using the keyword _ _ (Java 16+).":
      "RECORD",
  "In Java, define a fixed set of named constants as a type using _ _.": "ENUM",
  "In Java, indicate that a variable may refer to no object using the literal _ _.":
      "NULL",
  "In Java, introduce the checked-exception list after a method signature with the keyword _ _.":
      "THROWS",
  "In Java, mark a field so reads/writes go to main memory (no thread-local caching) with the keyword _ _.":
      "VOLATILE",
};
