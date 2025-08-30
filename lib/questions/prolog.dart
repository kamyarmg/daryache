// Prolog Q&A
const Map<String, String> qAProlog = {
  "In Prolog, a simple statement about the world is called a _ _.": "FACT",
  "In Prolog, a clause of the form Head :- Body. is called a _ _.": "RULE",
  "In Prolog, you ask the system a question by entering a _ _ at the ?- prompt.":
      "QUERY",
  "In Prolog, variable names begin with an _ _ letter or an underscore.":
      "UPPERCASE",
  "In Prolog, a relation is defined by a _ _ over its arguments.": "PREDICATE",
  "In Prolog, lists can be deconstructed with [H | T]; the symbol | is called the _ _.":
      "PIPE",
  "In Prolog, write logical 'and' between goals with a _ _.": "COMMA",
  "In Prolog, write logical 'or' between goals with a _ _.": "SEMICOLON",
  "In Prolog, evaluate arithmetic expressions and bind a result using the operator _ _, as in X is 1+2.":
      "IS",
  "In Prolog, the operator ':-' in a rule is often called the _ _.": "NECK",
  "In Prolog, the predicate that always succeeds is _ _.": "TRUE",
  "In Prolog, the predicate that always fails is _ _.": "FAIL",
  "In Prolog, the operator ! that commits to choices is called the _ _.": "CUT",
  "In Prolog, add a clause to the database at runtime with _ _/1.": "ASSERT",
  "In Prolog, remove a clause from the database at runtime with _ _/1.":
      "RETRACT",
  "In Prolog, declare that a predicate may be modified at runtime with the directive :- _ _.":
      "DYNAMIC",
  "In Prolog, declare a module with the directive :- _ _(...).": "MODULE",
  "In Prolog, a lowercase identifier like foo is an _ _.": "ATOM",
  "In Prolog, a term with a functor and arguments, like point(1,2), is a _ _ term.":
      "COMPOUND",
  "In Prolog, a single-line comment starts with the character _ _.": "PERCENT",
  "In Prolog, a clause ends with a _ _.": "PERIOD",
  "In Prolog, the standard relation for concatenating lists is _ _/3.":
      "APPEND",
  "In Prolog, check if a term is a variable using the built-in predicate _ _.":
      "VAR",
  "In Prolog, check if a term is not a variable using the built-in predicate _ _.":
      "NONVAR",
  "In Prolog, create choice points during backtracking with alternative _ _.":
      "SOLUTIONS",
  "In Prolog, unification is the process of making two terms _ _.": "EQUAL",
  "In Prolog, the built-in predicate to read terms from input is _ _.": "READ",
  "In Prolog, the built-in predicate to write terms to output is _ _.": "WRITE",
  "In Prolog, repeat alternative solutions until one succeeds using _ _.":
      "REPEAT",
  "In Prolog, check the length of a list using the predicate _ _.": "LENGTH",
  "In Prolog, check if an element is a member of a list using _ _.": "MEMBER",
  "In Prolog, sort a list using the built-in predicate _ _.": "SORT",
  "In Prolog, check if two terms unify without binding variables using _ _.":
      "UNIFIABLE",
};
