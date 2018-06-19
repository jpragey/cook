import ceylon.collection { LinkedList }
import org.cook.graph {
    Cycle,
    includeDeps,
    IdentifiableGraph,
    Graph
}


void sortDemo() {
    class MyNode(shared String name, shared [MyNode *] dependencies = []) {
        shared actual String string => name;        
    }
    
    MyNode node0 = MyNode("N0");
    MyNode node1 = MyNode("N1");
    MyNode node2 = MyNode("N2", [node0, node1]);
    Graph<MyNode> myGraph = IdentifiableGraph({node1, node2, node0}, (MyNode node) => node.dependencies);
    
    <[MyNode *] | Cycle<MyNode>> sortedGraph = myGraph.sort();
    print("Result: ``sortedGraph``");   // "Result: [N1, N0, N2]"
}

void acyclicCopyDemo() {
    // -- Source graph
    class SourceNode(shared String name, shared [SourceNode *] dependencies = []) {
        shared actual String string => name;        
    }
    
    SourceNode node0 = SourceNode("N0");
    SourceNode node1 = SourceNode("N1");
    SourceNode node2 = SourceNode("N2", [node0, node1]);
    Graph<SourceNode> sourceGraph = IdentifiableGraph({node1, node2, node0}, (SourceNode node) => node.dependencies);
    
    // -- Target graph (immutable dependencies)
    class TargetNode(shared String name, shared [TargetNode *] dependencies = []) {
        shared actual String string => "Target[``name``]";        
    }
    // Auxilary: createNode() converts a SourceNode to a TargetNode; all dependencies will be provided 
    TargetNode createNode(SourceNode original, [TargetNode *] dependencies)
        => TargetNode(original.name, dependencies);
    
    // -- Copy graph
    [TargetNode *]|Cycle<SourceNode> targetNodes = sourceGraph.copyAcyclic(createNode);
    print("Result: ``targetNodes``");   // Result: [Target[N1], Target[N0], Target[N2]]
    
}
void cyclicCopyDemo() {
    // -- Source graph
    class SourceNode(shared String name, shared LinkedList<SourceNode> dependencies = LinkedList<SourceNode>()) {
        shared actual String string => name;        
    }
    
    SourceNode node0 = SourceNode("N0");
    SourceNode node1 = SourceNode("N1");
    node0.dependencies.add(node1);  // create cycle
    node1.dependencies.add(node0);
    Graph<SourceNode> sourceGraph = IdentifiableGraph({node0, node1}, (SourceNode node) => node.dependencies.sequence());
    
    // -- Target graph (immutable dependencies)
    class TargetNode(shared String name, shared LinkedList<TargetNode> dependencies = LinkedList<TargetNode>()) {
        shared actual String string => "Target[``name``]";
    }
    // -- Copy graph
    [TargetNode *]|Cycle<SourceNode> targetNodes = sourceGraph.copyCyclic {
        // createNode converts a SourceNode to a TargetNode; dependencies will be provided later 
        createNode = (SourceNode original) => TargetNode(original.name);
        // add a dependency to an existing TargetNode 
        appendDep = (TargetNode container, TargetNode dependency) => container.dependencies.add(dependency);
    };
    
    print("Result: ``targetNodes``");   // Result: [Target[N0], Target[N1]]
    
}

void treeDemo() {
    
    class Node(shared String name, shared [Node *] dependencies = []) {
        shared actual String string => name;        
    }
    
    Node node0 = Node("N0");
    Node node1 = Node("N1");
    Node node2 = Node("N2", [node0, node1]);
    Graph<Node> graph = IdentifiableGraph({node2}, (Node node) => node.dependencies, includeDeps);
    
    print("Result: ``graph.nodes``");   // Result: [N2, N0, N1]
    
}


