// Data Structures Q&A
const Map<String, String> qADataStructures = {
  "In data structures, the linear collection that removes the most recently added item first (Last-In, First-Out) is a _ _.":
      "STACK",
  "In data structures, the linear collection that serves items in the order they were added (First-In, First-Out) is a _ _.":
      "QUEUE",
  "A linear structure supporting efficient insertion and removal at both the front and the back is a _ _.":
      "DEQUE",
  "Adding an element to the top of a stack is called _ _.": "PUSH",
  "Removing and returning the top element of a stack is called _ _.": "POP",
  "In a queue, inserting at the back is called _ _, while removing from the front is dequeue.":
      "ENQUEUE",
  "The access policy of stacks is abbreviated _ _ (last in, first out).":
      "LIFO",
  "The access policy of queues is abbreviated _ _ (first in, first out).":
      "FIFO",
  "A search tree where for each node, left keys are smaller and right keys are larger is a _ _.":
      "BST",
  "A self-balancing binary search tree that keeps heights logarithmic using rotations is an _ _ tree.":
      "AVL",
  "A balanced binary search tree with colored nodes enforcing structural invariants is a _ _ tree.":
      "REDBLACK",
  "An array-backed tree-ordered structure used to implement priority queues efficiently is a _ _.":
      "HEAP",
  "Building a binary heap from an arbitrary array via sift-down (heapify) runs in _ _ time (O(n)).":
      "LINEAR",
  "Graph traversal that explores vertices level by level and finds shortest paths in unweighted graphs is _ _.":
      "BFS",
  "Graph traversal that recursively explores as far as possible along each branch before backtracking is _ _.":
      "DFS",
  "A linear ordering of a directed acyclic graph where every edge goes from earlier to later is _ _.":
      "TOPOSORT",
  "The single-source shortest-path algorithm for graphs with nonnegative edge weights is _ _.":
      "DIJKSTRA",
  "The minimum spanning tree algorithm that grows a tree by always choosing the cheapest eligible edge is _ _.":
      "PRIM",
  "The minimum spanning tree algorithm that sorts edges and unions components is _ _.":
      "KRUSKAL",
  "A tree keyed by strings where each edge carries a character and prefixes form paths is a _ _.":
      "TRIE",
  "A probabilistic set structure that may return false positives but never false negatives is a _ _ filter.":
      "BLOOM",
  "A structure supporting prefix sums and point updates in logarithmic time is a _ _ tree (a.k.a. BIT).":
      "FENWICK",
  "A structure that supports range queries and updates by storing aggregates over intervals is a _ _.":
      "SEGTREE",
  "The set-partition structure supporting fast union and find with path compression is _ _.":
      "UNIONFIND",
  "Another common abbreviation for the disjoint-set union structure is _ _.":
      "DSU",
  "Representing a sparse graph by storing for each vertex its list of neighbors uses an _ _.":
      "ADJLIST",
  "Representing a dense graph with a V×V table of edges uses an adjacency _ _.":
      "MATRIX",
  "In-order traversal of a binary search tree visits keys in sorted order; the traversal name is _ _.":
      "INORDER",
  "Balanced parentheses checking and expression evaluation in reverse Polish notation are classic uses of a _ _.":
      "STACK",
  "The dictionary-like structure that maps keys to values using hashing is a _ _.":
      "HASHTABLE",
  "The expected time to lookup or insert in a well-sized hash table is _ _ (O(1)).":
      "CONSTANT",
  "Resolving hash collisions by keeping a linked list of entries per bucket is called _ _.":
      "CHAINING",
  "Resolving hash collisions by scanning alternative slots until a free one is found is _ _ probing.":
      "LINEAR",
  "The worst-case height of a well-balanced search tree on n keys is _ _ (O(log n)).":
      "LOGN",
  "Removing the minimum element from a min-heap is commonly called _ _-min.":
      "EXTRACT",
  "In a 1-based array heap, the parent of node i is at index floor(i / _ _).":
      "TWO",
  "The structural prerequisite of heaps—that the tree is complete except possibly the last level—is the _ _ property.":
      "SHAPE",
  "The linear-time string-matching algorithm that uses a prefix function (pi array) is _ _.":
      "KMP",
  "Substring search based on rolling hashes over the pattern and text is _ _.":
      "RABINKARP",
  "The step that splits data around a pivot during quicksort or selection is called _ _.":
      "PARTITION",
  "Maintaining a stack in monotonically increasing or decreasing order to answer next-greater/smaller queries uses a _ _ stack.":
      "MONOTONIC",
  "Maintaining the running median can be done with a max-heap and a _ _.":
      "MINHEAP",
  "An array-like buffer that wraps around and reuses freed space is a _ _ buffer.":
      "CIRCULAR",
  "A graph-theoretic structure where cycles are impossible is a _ _.": "DAG",
  "The number of edges incident to a vertex in an undirected graph is its _ _.":
      "DEGREE",
  "The tree used in databases that stores many keys per node and stays balanced by splitting nodes is a _ _.":
      "BTREE",
  "A hashing scheme that resolves collisions by relocating keys between two or more tables is _ _ hashing.":
      "CUCKOO",
  "In binary search, at each step we compare the target with the _ _ element of the current range.":
      "MIDDLE",
  "Detecting cycles in a directed graph with depth-first search requires tracking a recursion _ _.":
      "STACK",
  "A dynamic array that doubles its capacity on overflow gives push operations _ _ O(1) cost.":
      "AMORTIZED",
};
