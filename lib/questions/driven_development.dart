// Driven Development and Design (TDD, BDD, DDD, etc.) Q&A
const Map<String, String> qADrivenDevelopment = {
  "In Behavior-Driven Development, we specify expected behavior in business language (Given–When–Then); this approach is abbreviated _ _.":
      "BDD",
  "In Domain-Driven Design, we center code on a rich domain model aligned with business language; this is abbreviated _ _.":
      "DDD",
  "Defining acceptance tests with business partners first to guide implementation is Acceptance Test-Driven Development (_ _).":
      "ATDD",
  "Organizing work around small, client-valued features delivered in short iterations is _ _ (Feature-Driven Development).":
      "FDD",
  "Driving implementation from abstract, platform-independent models that can generate code is _ _ (Model-Driven Development).":
      "MDD",
  "Steering plans by addressing the riskiest elements first is _ _ (Risk-Driven Development).":
      "RDD",
  "In BDD, scenarios written in a business-readable syntax (Given/When/Then) use _ _.":
      "GHERKIN",
  "A popular tool that executes BDD scenarios written in Gherkin across many languages is _ _.":
      "CUCUMBER",
  "In TDD, the first step where you write a new failing test is _ _.": "RED",
  "In TDD, the step where you write the minimal code needed to pass the test is _ _.":
      "GREEN",
  "In TDD, the step where you improve design while keeping all tests passing is _ _.":
      "REFACTOR",
  "To isolate a unit under test, developers replace collaborators with test _ _ (e.g., stubs, mocks, fakes).":
      "DOUBLES",
  "A test double that verifies interactions (calls and arguments) is a _ _.":
      "MOCK",
  "A simple test double that returns canned values without behavior is a _ _.":
      "STUB",
  "In DDD, a cluster of domain objects that changes together under one consistency boundary is an _ _.":
      "AGGREGATE",
  "In DDD, an object distinguished by identity rather than just attributes is an _ _.":
      "ENTITY",
  "In DDD, the pattern mediating between the domain model and persistence for aggregates is a _ _.":
      "REPO",
  "In DDD, grouping changes to be committed atomically uses the UNIT OF WORK(_ _) pattern.":
      "UOW",
  "In BDD, the Given–When–Then structure is often abbreviated _ _ _.": "GWT",
};
