// Divide and Conquer Q&A
const Map<String, String> qADivideAndConquer = {
  "In the divide-and-conquer paradigm, the first phase that splits a problem into smaller subproblems is _ _.":
      "DIVIDE",
  "In the divide-and-conquer paradigm, the recursive phase that solves the subproblems is _ _.":
      "CONQUER",
  "In the divide-and-conquer paradigm, the final phase that merges partial results into a complete answer is _ _.":
      "COMBINE",
  "Sorting by repeatedly splitting an array into halves, sorting each half, and merging back together describes _ _.":
      "MERGESORT",
  "Sorting by partitioning around a pivot and recursively sorting the left and right partitions describes _ _.":
      "QUICKSORT",
  "Searching a sorted array by repeatedly halving the search interval (low, mid, high) is _ _.":
      "BINSEARCH",
  "Multiplying large integers faster than the classical O(n^2) method by using three recursive subproducts is _ _.":
      "KARATSUBA",
  "Multiplying matrices faster than the naive cubic algorithm by using seven 2x2 submultiplications is _ _.":
      "STRASSEN",
  "Computing the discrete Fourier transform in O(n log n) by splitting into even and odd indices is _ _.":
      "FFT",
  "Finding the closest pair of points in the plane in O(n log n) by dividing the set and checking a central strip is _ _.":
      "CLOSEST",
  "Raising a number to a power by halving the exponent and squaring intermediate results is exponentiation by _ _.":
      "SQUARING",
  "Selecting the k-th smallest element in expected linear time by partitioning like quicksort is quick_ _.":
      "SELECT",
  "Building a convex hull by splitting the point set, computing hulls, and merging them along a common tangent is the divide-and-conquer _ _ algorithm.":
      "HULL",
  "A classic tiling example that recursively covers a 2^n by 2^n board with one missing square uses the _ _ approach.":
      "TROMINO",
  "Many divide-and-conquer recurrences T(n) = a·T(n/b) + f(n) are solved using the _ _ theorem.":
      "MASTER",
  "Breaking problems into self-similar subproblems and solving them recursively relies fundamentally on _ _.":
      "RECURSION",
  "The base case in a divide-and-conquer algorithm prevents infinite _ _.":
      "RECURSION",
  "Merge sort has a time complexity of _ _ (O(n log n)) in all cases.": "NLOGN",
  "Quick sort's average case time complexity is _ _ (O(n log n)).": "NLOGN",
  "The divide-and-conquer approach to finding maximum and minimum elements in an array reduces comparisons to approximately _ _.":
      "THREENTWO",
  "The divide-and-conquer matrix multiplication algorithm by Strassen reduces the number of scalar multiplications from 8 to _ _.":
      "SEVEN",
  "Quick select algorithm finds the k-th order statistic in expected _ _ time.":
      "LINEAR",
  "Merge sort requires _ _ extra space for the temporary arrays during merging.":
      "LINEAR",
  "The convex hull divide-and-conquer algorithm has time complexity _ _.":
      "NLOGN",
  "Karatsuba multiplication reduces the complexity of multiplying n-digit numbers from O(n²) to approximately O(n^_).":
      "LOG3",
  "In the Master Theorem, if a = 1 and b = 2, the recurrence T(n) = T(n/2) + O(1) has solution _ _.":
      "LOGN",
  "The _ _ problem can be solved in O(n log n) using divide-and-conquer by splitting points and checking a middle strip.":
      "CLOSEST",
  "Polynomial multiplication can be done efficiently using divide-and-conquer with the _ _ transform.":
      "FOURIER",
  "The divide-and-conquer approach typically uses _ _ to break down problems into smaller instances.":
      "RECURSION",
  "Quick sort's worst-case occurs when the _ _ is always the smallest or largest element.":
      "PIVOT",
  "The number of leaves in a divide-and-conquer recursion tree often determines the algorithm's _ _ complexity.":
      "TIME",
  "Merge sort is _ _ sorting algorithm, meaning equal elements maintain their relative order.":
      "STABLE",
};
