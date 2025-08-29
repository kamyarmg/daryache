// Design Patterns (GoF) Q&A
const Map<String, String> qADesignPatternsGoF = {
  "In design patterns, the creational pattern that guarantees exactly one instance (e.g., a logger or config) and a globally accessible point to it is _ _.":
      "SINGLETON",
  "In design patterns, the pattern that enforces a single, lazily created instance with optional thread-safety (double‑checked locking) is _ _.":
      "SINGLETON",

  "In design patterns, the creational pattern that defers object creation to subclasses via a 'factory hook' so they decide which product to instantiate is _ _.":
      "FACTORYM",
  "In design patterns, the pattern where a Creator class exposes a method that returns a Product, letting subclasses choose the concrete type, is _ _.":
      "FACTORYM",

  "In design patterns, the creational pattern that produces families of related products (e.g., GUI widgets for a theme) without specifying their concrete classes is _ _.":
      "ABFACTORY",
  "In design patterns, the pattern that ensures compatible product variants are created together by a family‑aware factory interface is _ _.":
      "ABFACTORY",

  "In design patterns, the creational pattern that separates the construction of a complex object from its representation, enabling step‑by‑step assembly and fluent APIs, is _ _.":
      "BUILDER",
  "In design patterns, the pattern that can reuse the same construction steps to produce different representations is _ _.":
      "BUILDER",

  "In design patterns, the creational pattern that creates new objects by cloning existing exemplars (to avoid costly construction) is _ _.":
      "PROTOTYPE",
  "In design patterns, the pattern that often uses a registry of exemplar objects to copy new instances is _ _.":
      "PROTOTYPE",

  "In design patterns, the structural pattern that converts one interface to another so otherwise incompatible types can collaborate is _ _.":
      "ADAPTER",
  "In design patterns, the pattern that wraps an adaptee to match a target API (object or class form) is _ _.":
      "ADAPTER",

  "In design patterns, the structural pattern that decouples an abstraction from its implementation so both can vary independently is _ _.":
      "BRIDGE",
  "In design patterns, the pattern that replaces inheritance with composition by separating RefinedAbstraction from ConcreteImplementor is _ _.":
      "BRIDGE",

  "In design patterns, the structural pattern that lets clients treat individual objects and compositions uniformly using a tree structure is _ _.":
      "COMPOSITE",
  "In design patterns, the pattern with Leaf and Composite nodes that supports part‑whole hierarchies is _ _.":
      "COMPOSITE",

  "In design patterns, the structural pattern that adds responsibilities to an object dynamically by wrapping it without altering its class is _ _.":
      "DECORATOR",
  "In design patterns, the pattern that supports stacking wrappers (e.g., buffering + compression) to extend behavior is _ _.":
      "DECORATOR",

  "In design patterns, the structural pattern that offers a simplified, unified interface over a complex subsystem is _ _.":
      "FACADE",
  "In design patterns, the pattern used to reduce coupling by providing a coarse‑grained entry point to several APIs is _ _.":
      "FACADE",

  "In design patterns, the structural pattern that shares intrinsic state to support large numbers of fine‑grained objects efficiently is _ _.":
      "FLYWEIGHT",
  "In design patterns, the pattern that splits state into intrinsic (shared) and extrinsic (context) to lower memory is _ _.":
      "FLYWEIGHT",

  "In design patterns, the structural pattern that supplies a stand‑in object to control access, add caching, or defer initialization is _ _.":
      "PROXY",
  "In design patterns, the pattern whose variants include virtual, remote, and protection stand‑ins is _ _.":
      "PROXY",

  "In design patterns, the behavioral pattern that passes a request along a chain of handlers until one chooses to handle it is _ _ OF RESPONSIBILITY.":
      "CHAIN",
  "In design patterns, the pattern that decouples sender from receiver by giving multiple objects a chance to process a request is _ _ OF RESPONSIBILITY.":
      "CHAIN",

  "In design patterns, the behavioral pattern that turns a request into a standalone object so you can queue, log, or undo operations is _ _.":
      "COMMAND",
  "In design patterns, the pattern with Invoker, Command, and Receiver that supports undo/redo is _ _.":
      "COMMAND",

  "In design patterns, the behavioral pattern that provides sequential access to elements of a collection without exposing its internals is _ _.":
      "ITERATOR",
  "In design patterns, the pattern that supports multiple cursors and traversal strategies over aggregates is _ _.":
      "ITERATOR",

  "In design patterns, the behavioral pattern that centralizes complex communication among objects to reduce coupling is _ _.":
      "MEDIATOR",
  "In design patterns, the pattern that replaces many‑to‑many colleague references with a single coordinator is _ _.":
      "MEDIATOR",

  "In design patterns, the behavioral pattern that captures and restores an object’s internal state without breaking encapsulation is _ _.":
      "MEMENTO",
  "In design patterns, the pattern featuring Originator, Memento, and Caretaker for rollback is _ _.":
      "MEMENTO",

  "In design patterns, the behavioral pattern where dependents subscribe to a subject and are notified automatically when its state changes is _ _.":
      "OBSERVER",
  "In design patterns, the pattern that models publish/subscribe with one‑to‑many updates is _ _.":
      "OBSERVER",

  "In design patterns, the behavioral pattern that lets an object change its behavior when its internal mode changes by delegating to state objects is _ _.":
      "STATE",
  "In design patterns, the pattern that replaces conditional logic with polymorphic mode objects is _ _.":
      "STATE",

  "In design patterns, the behavioral pattern that encapsulates interchangeable algorithms behind a common interface to vary behavior at runtime is _ _.":
      "STRATEGY",
  "In design patterns, the pattern that lets you swap policies (e.g., sort, route, price) without changing the context is _ _.":
      "STRATEGY",

  "In design patterns, the behavioral pattern that defines an algorithm’s skeleton in a base class while deferring selected steps to subclasses is _ _ Method.":
      "TEMPLATE",
  "In design patterns, the pattern that uses invariant steps plus overridable hooks within a fixed procedure is _ _ Method.":
      "TEMPLATE",

  "In design patterns, the behavioral pattern that adds new operations to object structures without modifying element classes by separating traversal from actions is _ _.":
      "VISITOR",
  "In design patterns, the pattern that enables double dispatch to apply many operations across a stable hierarchy is _ _.":
      "VISITOR",
};
