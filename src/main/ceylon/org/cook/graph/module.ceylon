"Basic directed graph library.
 
 This module manages [[Graph]]s of nodes, connected by dependencies (or 'edges'); it provides:
 - topological sorting: sort nodes so that each node depends only on previous nodes;
 - graph comparison;
 - graph copying, with conversion (convert a Graph<XNode> to a Graph<YNode>, with same topology).
  
 Many operation depend on the 'sameness' of nodes; however there is no unique notion of sameness,
 so two graphs are defined:
 - [[IdentifiableGraph]], where nodes are compared by '===': nodes must satisfy [[Identifiable]]. 
    `hash` is also used, but the default (Object) implementation is OK; 
 - [[ValueGraph]], where nodes are compared by '==': nodes must extend [[Object]], nulls are not allowed. 
    A suitable node `hash` method must be provided.
 
 # Basic usage: sort a graph
                                                                                                                                                }
     void sortDemo() {
         // -- Node
         class MyNode(shared String name, shared [MyNode *] dependencies = []) {
            shared actual String string => name;        
         }
     
         // -- Graph
         MyNode node0 = MyNode(\"N0\");
         MyNode node1 = MyNode(\"N1\");
         MyNode node2 = MyNode(\"N2\", [node0, node1]);
         Graph<MyNode> myGraph = IdentifiableGraph({node1, node2, node0}, (MyNode node) => node.dependencies);
                                                                                       
         <[MyNode *] | Cycle<MyNode>> sortedGraph = myGraph.sort();
         print(\"Result: \`\`sortedGraph\`\`\");   // \"Result: [N1, N0, N2]\"
     }                                                                                                                                   }
 Notes:
 - there are very few restrictions node class - no special interface to implement. Dependencies are provided to 
   [[IdentifiableGraph]] as a function, so they can be stored anywhere (no need to include them in nodes, although it's usually convenient);
 - graphs can handle cycles;
 - dependencies can be immutable. There's a restriction on graph copying - you can't create a cycling graph if dependencies are immutable -,
   but other methods are OK;

 # Graph construction
 --------------------

 [[IdentifiableGraph]] and [[ValueGraph]] have the same initializer parameters:
    
     IdentifiableGraph<Node>(shared {Node *} initialNodes, shared [Node *] dependencies(Node node),
        DependenciesCheck checkDependencies = dontCheckMissingDep)
 
     ValueGraph<Node>(shared {Node *} initialNodes, shared [Node *] dependencies(Node node),
        DependenciesCheck checkDependencies = dontCheckMissingDep) 

 The graph builds its node list by first including [[IdentifiableGraph.initialNodes]]; it may add their dependencies, 
 depending on [[IdentifiableGraph.checkDependencies]]: 
 - if it's [[includeDeps]]: dependencies are (recursively) added to the node list; 
 - if it's [[throwIfMissingDep]]: [[IdentifiableGraph.initialNodes]] is supposes to hold all nodes. If a dependency doesn't belong to it,
   a [[GraphException]] is thrown;
 - if it's [[dontCheckMissingDep]], no check is performed, [[IdentifiableGraph.initialNodes]] is supposes to hold all dependecy nodes.
   It's a bit dangerous but it's faster.
      
 Examples:
     class Node(shared String name, shared [Node *] dependencies = []) {
        shared actual String string => name;        
     }
       
     void constructDemo() {
        Node node0 = Node(\"N0\");
        Node node1 = Node(\"N1\");
        Node node2 = Node(\"N2\", [node0, node1]);
        [Node *] dependencies(Node node) => node.dependencies;
       
        // -- test with includeDeps
        Graph<Node> graph = IdentifiableGraph({node2}, dependencies, includeDeps);
        assertThat(graph.nodes, contains { eq(node2), eq(node0), eq(node1) });
        print(\"Result: \'\'graph.nodes\'\'\");   // Result: [N2, N0, N1]
      
        // -- test with includeDeps
        try {
            IdentifiableGraph({node2}, dependencies, throwIfMissingDep);
            throw AssertionException(\"A GraphException was expected\");
        } catch(GraphException expected) {
            print(\"Exception Result: \'\'expected\'\'\");   // Result: herd.algo.graph.GraphException \"Dependency node N0 does not belong to nodes [N2]\"
        }
     
        // -- test with dontCheckMissingDep (dangerous here: dependencies outside graph)
        Graph<Node> graph2 = IdentifiableGraph({node2}, dependencies, dontCheckMissingDep);
        assertThat(graph2.nodes, contains { eq(node2) });
        print(\"Result: \'\'graph2.nodes\'\'\");   // Result: [N2]
     }
       
 
 # Graph copying
 ---------------
 [[Graph]] provides two methods to copy a graph (to possibly different node types), depending on how cycles must be handled:
 - [[Graph.copyAcyclic]] copies only acyclic graph; if a cycle is found, it fails by returning a [[Cycle]].
   Its target nodes can have immutable dependencies. 
 - [[Graph.copyCyclic]] copies both cyclic and acyclic graphs, but require target nodes to have mutable dependencies.
 
 Copying acyclic graph:
    
      void acyclicCopyDemo() {
         // -- Source graph
         class SourceNode(shared String name, shared [SourceNode *] dependencies = []) {
            shared actual String string => name;        
         }
     
         SourceNode node0 = SourceNode(\"N0\");
         SourceNode node1 = SourceNode(\"N1\");
         SourceNode node2 = SourceNode(\"N2\", [node0, node1]);
         Graph<SourceNode> sourceGraph = IdentifiableGraph({node1, node2, node0}, (SourceNode node) => node.dependencies);
       
         // -- Target graph (immutable dependencies)
         class TargetNode(shared String name, shared [TargetNode *] dependencies = []) {
            shared actual String string => \"Target[\`\`name\`\`]\";        
         }
         // Auxilary: createNode() converts a SourceNode to a TargetNode; all dependencies will be provided 
         TargetNode createNode(SourceNode original, [TargetNode *] dependencies)
            => TargetNode(original.name, dependencies);
        
         // -- Copy graph
         [TargetNode *]|Cycle<SourceNode> targetNodes = sourceGraph.copyAcyclic(createNode);
         print(\"Result: \`\`targetNodes\`\`\");   // Result: [Target[N1], Target[N0], Target[N2]]
      }
 
 Copying graph with cycle:
 
     void cyclicCopyDemo() {
         // -- Source graph
         class SourceNode(shared String name, shared LinkedList<SourceNode> dependencies = LinkedList<SourceNode>()) {
            shared actual String string => name;        
         }
         
         SourceNode node0 = SourceNode(\"N0\");
         SourceNode node1 = SourceNode(\"N1\");
         node0.dependencies.add(node1);  // create cycle
         node1.dependencies.add(node0);
         Graph<SourceNode> sourceGraph = IdentifiableGraph({node0, node1}, (SourceNode node) => node.dependencies.sequence);
             
         // -- Target graph (immutable dependencies)
         class TargetNode(shared String name, shared LinkedList<TargetNode> dependencies = LinkedList<TargetNode>()) {
             shared actual String string => \"Target[\'\'name\'\']\";
         }
              
         // -- Copy graph
         [TargetNode *]|Cycle<SourceNode> targetNodes = sourceGraph.copyCyclic {
            // createNode converts a SourceNode to a TargetNode; dependencies will be provided later 
            createNode = (SourceNode original) => TargetNode(original.name);
            // add a dependency to an existing TargetNode 
            appendDep = (TargetNode container, TargetNode dependency) => container.dependencies.add(dependency);
         };
         print(\"Result: \'\'targetNodes\'\'\");   // Result: [Target[N0], Target[N1]]
     }
 
 "





module org.cook.graph "1.0.0" {
    //import java.base "7";
    import ceylon.collection "1.3.3";
}
