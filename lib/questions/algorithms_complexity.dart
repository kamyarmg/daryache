// Algorithms and Complexity Q&A
const Map<String, String> qAAlgorithmsComplexity = {
  "In algorithm analysis, the notation _ _ (written O(f(n))) gives an asymptotic upper bound (up to constant factors) on time or space complexity.":
      "BIGO",
  "In algorithm analysis, the notation _ _ (written Θ(f(n))) gives a tight asymptotic bound (both upper and lower, within constant factors).":
      "BIGTHETA",
  "In algorithm analysis, the notation _ _ (written Ω(f(n))) gives an asymptotic lower bound on growth.":
      "BIGOMEGA",
  "An algorithm that runs in time independent of the input size n has _ _ time (e.g., O(1) array access).":
      "CONSTANT",
  "An algorithm whose running time grows in direct proportion to the input size n has _ _ time (e.g., a single pass over the data).":
      "LINEAR",
  "An algorithm whose time grows proportional to n squared has _ _ time (e.g., two nested loops over the input).":
      "QUADRATIC",
  "An algorithm whose time grows proportional to n! has _ _ time (e.g., brute-force permutations).":
      "FACTORIAL",
  "Linear search over an unsorted array of length n runs in _ _ time in the worst case (O(n)).":
      "LINEAR",
  "The average-case time complexity of quicksort is _ _ (O(n log n)).": "NLOGN",
  "The worst-case time complexity of quicksort is _ _ (O(n^2), e.g., bad pivot choices).":
      "QUADRATIC",
  "Merge sort runs in _ _ time in the worst case (O(n log n)).": "NLOGN",
  "The extra auxiliary space used by merge sort on arrays is _ _ (O(n)).":
      "LINEAR",
  "Heapsort runs in _ _ time in the worst case (O(n log n)).": "NLOGN",
  "Any comparison-based sorting algorithm requires, in the worst case, at least _ _ comparisons (information-theoretic lower bound).":
      "NLOGN",
  "For sufficiently large n, O(log n) grows _ _ than O(n) (i.e., asymptotically).":
      "SLOWER",
  "As n increases, O(n) is _ _ than O(n log n) (asymptotically smaller).":
      "SMALLER",
  "If f(n) grows strictly slower than g(n), we write f(n) = _ _(g(n)) (non-tight upper bound).":
      "LITTLEO",
  "When f(n) and g(n) bound each other asymptotically within constant factors, we write f(n) = _ _(g(n)).":
      "THETA",
  "Analyzing the average cost per operation over a sequence of operations is called _ _ analysis (e.g., dynamic array push).":
      "AMORTIZED",
  "An algorithm that requires exponential space or time has complexity of the form _ _ where a is a constant greater than 1.":
      "ATON",
  "The time complexity of finding the maximum element in an unsorted array is _ _ (O(n)).":
      "LINEAR",
  "Matrix multiplication using the standard algorithm has _ _ time complexity (O(n³)).":
      "CUBIC",
  "The space complexity of recursion depends on the maximum _ _ depth.": "CALL",
  "An algorithm that uses a fixed amount of extra space regardless of input size has _ _ space complexity.":
      "CONSTANT",
  "The Master Theorem helps analyze the complexity of _ _ algorithms.":
      "DIVIDE",
  "Hash table operations have _ _ average time complexity for search, insert, and delete.":
      "CONSTANT",
  "The worst-case time complexity of hash table operations is _ _ when many collisions occur.":
      "LINEAR",
  "Depth-first search (DFS) on a graph with V vertices and E edges has time complexity _ _.":
      "VPLUSKE",
  "Breadth-first search (BFS) on a graph has the same time complexity as DFS, which is _ _.":
      "VPLUSKE",
  "Dijkstra's algorithm using a binary heap has time complexity _ _ where V is vertices and E is edges.":
      "ELOGV",
  "The time complexity of building a heap from an unsorted array is _ _ (O(n)).":
      "LINEAR",
  "Counting sort has _ _ time complexity where n is array size and k is range of input values.":
      "NPLUSK",
  "Radix sort has time complexity _ _ where d is the number of digits.": "DNK",
  "The _ _ problem asks whether P equals NP, one of the most famous unsolved problems in computer science.":
      "PVSNP",
};
