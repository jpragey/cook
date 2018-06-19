import ceylon.test {
	test,
	assertEquals
}

import org.cook.graph {
	GraphException,
	dontCheckMissingDep,
	includeDeps,
	IdentifiableGraph,
	Graph,
	throwIfMissingDep
}


shared class GraphConstructionTest() {
    // -- Source graph
    class Node(shared String name, shared [Node *] dependencies = []) {
        shared actual String string => name;        
    }
    

    test shared void constructByIncludingDeps() {
        Node node0 = Node("N0");
        Node node1 = Node("N1");
        Node node2 = Node("N2", [node0, node1]);
        [Node *] dependencies(Node node) => node.dependencies;
        
        // -- test with includeDeps
        Graph<Node> graph = IdentifiableGraph({node2}, dependencies, includeDeps);
        //assertThat(graph.nodes, contains { eq(node2), eq(node0), eq(node1) });
        
        assert(graph.nodes.contains(node0));
        assert(graph.nodes.contains(node1));
        assert(graph.nodes.contains(node2));
        
        //print("Result: ``graph.nodes``");   // Result: [N2, N0, N1]
        
        // -- test with includeDeps
        try {
            IdentifiableGraph({node2}, dependencies, throwIfMissingDep);
            throw AssertionError("A GraphException was expected");
        } catch(GraphException expected) {
            //print("Exception Result: ``expected``");   // Result: herd.algo.graph.GraphException "Dependency node N0 does not belong to nodes [N2]"
        }
        
        // -- test with dontCheckMissingDep (dangerous here: dependencies outside graph)
        Graph<Node> graph2 = IdentifiableGraph({node2}, dependencies, dontCheckMissingDep);
        //assertThat(graph2.nodes, contains { eq(node2) });
        assert(graph2.nodes.contains(node2));
        //print("Result: ``graph2.nodes``");   // Result: [N2]
    }


    String[] buildGraphWithDeps(Node* initials) {
        Graph<Node> graph = IdentifiableGraph(initials, (Node node) => node.dependencies, includeDeps);
        return graph.nodes *.name;
    }
    
    
    test shared void constructionWithDepsKeepsInitialNodesInOrder() {
        Node node1 = Node("N1");
        Node node2 = Node("N2", [node1]);
        Node node3 = Node("N3");
        Node node4 = Node("N4", [node3]);
        Node node5 = Node("N5");
        Node node6 = Node("N6", [node5]);
        
        assertEquals(buildGraphWithDeps(node2, node4, node6)[0:3], ["N2", "N4", "N6"]);
        assertEquals(buildGraphWithDeps(node6, node4, node2)[0:3], ["N6", "N4", "N2"]);
        
    }
    
    
}
