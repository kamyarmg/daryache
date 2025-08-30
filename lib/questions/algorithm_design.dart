// Algorithm Design Q&A
const Map<String, String> qAAlgorithmDesign = {
  "In algorithm design, building a solution step by step by always taking the locally optimal choice is called _ _.":
      "GREEDY",
  "In algorithm design, breaking a problem into overlapping subproblems and using optimal substructure is abbreviated _ _.":
      "DP",
  "In dynamic programming, top-down recursion with cached results is _ _.":
      "MEMOIZE",
  "In dynamic programming, bottom-up computation that fills a table iteratively is _ _.":
      "TABULATE",
  "Systematically exploring choices and undoing them when they lead to dead ends is _ _.":
      "BACKTRACK",
  "Eliminating branches that cannot improve the best known answer is _ _.":
      "PRUNING",
  "Maintaining a moving window that expands and contracts while preserving an invariant is the _ _ window technique.":
      "SLIDING",
  "Processing sorted events while keeping an active set of candidates is the _ _LINE method.":
      "SWEEP",
  "Using two indices that move monotonically to maintain a valid state is the two _ _ technique.":
      "POINTERS",
  "Searching over the answer space with a monotone feasibility test uses _ _ search on answer.":
      "BINARY",
  "Splitting the set, enumerating each half, then combining partial results is _ _ in the middle.":
      "MEET",
  "Encoding subsets with bits to compress state and iterate efficiently is _ _ DP.":
      "BITMASK",
  "Choosing items under a capacity limit via DP is the classic 0/1 _ _ problem.":
      "KNAPSACK",
  "Finding the extremum of a unimodal function on an interval with tri-partitioning is _ _ search.":
      "TERNARY",
  "Optimizing DP over lines by keeping a deque of best candidates is the convex _ _.":
      "HULLTRICK",
  "Proving greedy correctness by swapping choices uses the _ _ argument.":
      "EXCHANGE",
  "Reasoning about correctness or termination by tracking a quantity that never violates a rule relies on an _ _.":
      "INVARIANT",
  "Bounding total cost over a sequence of operations with a stored credit is the _ _ method.":
      "POTENTIAL",
  "Introducing randomness to simplify logic or achieve expected bounds yields a _ _ algorithm.":
      "RANDOM",
  "Iterating all submasks of a bitmask to consider only feasible subsets is _ _ iteration.":
      "SUBMASK",
  "A DP hallmark where many subproblems repeat is having _ _ subproblems.":
      "OVERLAP",
  "A key DP property: an optimal whole can be formed from optimal parts; this is _ _ substructure.":
      "OPTIMAL",
  "Using a deque that stays increasing or decreasing to maintain window minima/maxima is a _ _ queue.":
      "MONOTONIC",
  "Guiding search by a scoring rule to explore promising states first is a _ _ search.":
      "HEURISTIC",
  "Precomputing jump pointers to answer ancestor or LCA queries quickly is _ _ lifting.":
      "BINARY",
  "Answering range sums fast by precomputing cumulative totals uses _ _ sums.":
      "PREFIX",
  "Applying many range updates by storing deltas then taking a prefix uses the _ Array technique.":
      "DIFFERENCE",
  "Searching for the best parameter by embedding a decision procedure is _ _ search.":
      "PARAMETRIC",
  "Maintaining the best solution found so far while exploring the solution space is _ _ optimization.":
      "LOCAL",
  "Building solutions by always choosing the best immediate option defines _ _ strategy.":
      "GREEDY",
  "Testing algorithm correctness by running it on many automatically generated inputs is _ _ testing.":
      "PROPERTY",
  "Reducing a hard problem to a known hard problem to prove computational difficulty uses _ _.":
      "REDUCTION",
};
