// Rust Q&A
const Map<String, String> qARust = {
  "In Rust, every executable program starts in the function named _ _.": "MAIN",
  "In Rust, we declare a function with the keyword _ _.": "FN",
  "In Rust, to create a variable binding, use the keyword _ _.": "LET",
  "In Rust, to make a binding mutable, add the keyword _ _.": "MUT",
  "In Rust, to print a line to standard output, use the _ _! macro.": "PRINTLN",
  "In Rust, the pattern-matching control-flow construct is _ _.": "MATCH",
  "In Rust, the keyword for an infinite loop is _ _.": "LOOP",
  "In Rust, transferring ownership of a value is called a _ _.": "MOVE",
  "In Rust, temporarily accessing data without taking ownership is called _ _.":
      "BORROWING",
  "In Rust, to take an immutable reference, prefix a value with the symbol _ _.":
      "AMPERSAND",
  "In Rust, the error-handling type that is either Ok or Err is _ _.": "RESULT",
  "In Rust, the type that may or may not contain a value is _ _.": "OPTION",
  "In Rust, to bring names into scope, use the keyword _ _.": "USE",
  "In Rust, to expose an item outside its module, mark it _ _.": "PUB",
  "In Rust, declare a new module with the keyword _ _.": "MOD",
  "In Rust, the block used to implement methods or traits for a type starts with _ _.":
      "IMPL",
  "In Rust, define a record-like data type with the keyword _ _.": "STRUCT",
  "In Rust, define a tagged union (sum type) with the keyword _ _.": "ENUM",
  "In Rust, to define shared behavior that types can implement, declare a _ _.":
      "TRAIT",
  "In Rust, the smart pointer that allocates values on the heap is _ _<T>.":
      "BOX",
  "In Rust, the growable contiguous sequence type is _ _<T>.": "VEC",
  "In Rust, the thread-safe, reference-counted smart pointer for shared ownership is _ _<T>.":
      "ARC",
  "In Rust, the attribute that marks a unit test function is #[_ _].": "TEST",
  "In Rust, automatically implement common traits with #[_ _(...)].": "DERIVE",
  "In Rust, an asynchronous function is declared with the keyword _ _.":
      "ASYNC",
  "In Rust, inside an async context, wait for a Future with _ _.": "AWAIT",
  "In Rust, create an iterator from a collection with _ _().": "ITER",
  "In Rust, collect an iterator into a collection with _ _().": "COLLECT",
  "In Rust, the tool used to build, run, and manage packages is _ _.": "CARGO",
  "In Rust, a library or executable package is called a _ _.": "CRATE",
  "In Rust, the attribute for conditional compilation is #[_ _(...)].": "CFG",
  "In Rust, declaring a new binding with the same name to hide the previous one is called _ _.":
      "SHADOWING",
  "In Rust, to immediately exit the current loop, use the keyword _ _.":
      "BREAK",
  "In Rust, to skip to the next iteration of the current loop, use _ _.":
      "CONTINUE",
  "In Rust, to return from a function (optionally with a value), use _ _.":
      "RETURN",
  "In Rust, the immutable string slice type is _ _.": "STR",
  "In Rust, the growable, heap-allocated owned string type is _ _.": "STRING",
  "In Rust, a non-owning view into a contiguous sequence is a _ _.": "SLICE",
  "In Rust, to mark code that may violate safety guarantees, use _ _.":
      "UNSAFE",
  "In Rust, define a compile-time constant with _ _.": "CONST",
  "In Rust, declare a variable with static lifetime using _ _.": "STATIC",
  "In Rust, create a formatted String without printing using the _ _!(...) macro.":
      "FORMAT",
  "In Rust, bring an item into scope under a different name using _ _.": "AS",
  "In Rust, the trait for programmer-facing {:?} formatting is _ _.": "DEBUG",
  "In Rust, the trait for user-facing {} formatting is _ _.": "DISPLAY",
  "In Rust, dynamically dispatched trait objects are prefixed with _ _.": "DYN",
  "In Rust, in function signatures, accept an anonymous implementor using the type syntax _ _ Trait.":
      "IMPL",
  "In Rust, create a non-thread-safe reference-counted pointer with _ _<T>.":
      "RC",
  "In Rust, enable interior mutability checked at runtime with _ _<T>.":
      "REFCELL",
  "In Rust, refer to the parent module using _ _.": "SUPER",
  "In Rust, define type aliases with the keyword _ _.": "TYPE",
  "In Rust, specify trait constraints after a signature with a _ _ clause.":
      "WHERE",
  "In Rust, perform an infallible conversion using _ _.": "FROM",
  "In Rust, consume a value to convert it into another type using _ _.": "INTO",
  "In Rust, run code when a value goes out of scope by implementing _ _.":
      "DROP",
  "In Rust, pin a value to a stable memory address with _ _<T>.": "PIN",
  "In Rust, types that can move even when pinned implement _ _.": "UNPIN",
  "In Rust, spawn a new thread with std::thread::_ _(...).": "SPAWN",
  "In Rust, wait for a spawned thread to finish using _ _().": "JOIN",
  "In Rust, loop while a condition holds using _ _.": "WHILE",
  "In Rust, anonymous functions that can capture their environment are called _ _.":
      "CLOSURES",
  "In Rust, a closure that can be called only once implements _ _.": "FNONCE",
  "In Rust, install and manage Rust toolchains with _ _.": "RUSTUP",
  "In Rust, declare a function with the C ABI using _ _.": "EXTERN",
  "In Rust, the type of functions that never return is _ _ (written !).":
      "NEVER",
  "In Rust, use _ _ for concise pattern matching on a single pattern.": "IFLET",
  "In Rust, loop while destructuring with pattern matching using _ _.":
      "WHILELET",
  "In Rust, the clone-on-write smart pointer for borrowed or owned data is _ _<T>.":
      "COW",
  "In Rust, the standard associative map from keys to values is _ _<K, V>.":
      "HASHMAP",
};
