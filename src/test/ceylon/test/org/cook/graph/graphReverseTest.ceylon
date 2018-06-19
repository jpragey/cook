import ceylon.test {
	test,
	assertEquals
}

import org.cook.graph {
	Cycle,
	includeDeps,
	IdentifiableGraph
}




shared class GraphReverseTest() {
     // -- Source graph
    class Node(shared String name, shared [Node *] dependencies = []) {
        shared actual String string => "``name``=>`` {for(n in dependencies) n.name}``";
        shared actual Boolean equals(Object that) {
            if(is Node that) {
                return that.name == name;        
            }
            return false;
        }
    }
    
    //object nameMatcher satisfies Matcher<Node> {
    //    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {}
    //    
    //    shared actual void describeTo(TextBuilder textBuilder) {}
    //    
    //    shared actual Description explainFully(Anything actual, Descriptor descriptor) => nothing;
    //    
    //    shared actual Boolean match(Anything actual) => nothing;
    //    
    //    
    //    
    //}
    //Matcher<Node> nameMatcher(String nodeName) => equalTo(name);
    ////shared EqualsOpMatcher<T> eq<T>(T expected) => equalTo(expected); 

/**    
    Matcher<Node> eqn(String name, [String *] depNames) => ObjectMatcher<Node>(
        AttributeMatcher(eq<String>(name), `Node.name`),
        AttributeMatcher(contains { for(n in depNames) eq(n)}, `Node.dependencies`, (Node obj) => {for(d in obj.dependencies) d.name})
        //AttributeMatcher(contains { for(n in depNames) nameMatcher(n)}, `Node.dependencies`)
    );
   */
    
    
     
    test shared void doTest() {
        Node node00 = Node("N00");
        Node node01 = Node("N01");
        Node node0 =  Node("N0", [node00, node01]);
        
        Node node10 = Node("N10");
        Node node11 = Node("N11");
        Node node1  = Node("N1", [node10, node11, node00]);
        
        Node node = Node("N", [node0, node1]);
        
        IdentifiableGraph<Node> graph = IdentifiableGraph(
            {node, node0, node1, node00, node01, node10, node11}, 
            (Node node) => node.dependencies, includeDeps);
        
        Node createNode (Node node, [Node *] reverseDeps /* new (reverse) dependencies*/) => Node(node.name, reverseDeps);
        <[Node *]|Cycle<Node>> reversed = graph.acyclicReverse{createNode = createNode; keepNodesOrder = true;};
        
        assert(is [Node *] reversed);
        
        void checkReverseContains(String nodeName, String[] depNames) {
            assert(is Node node = reversed.find((Node n) =>n.name == nodeName));
            assertEquals(node.dependencies*.name, depNames);
        }
        
        checkReverseContains("N0", ["N"]);
        
        checkReverseContains("N", []); 
        checkReverseContains("N0", ["N"]); 
        checkReverseContains("N1", ["N"]); 
        checkReverseContains("N00", ["N0", "N1"]); 
        checkReverseContains("N01", ["N0"]);
        checkReverseContains("N10", ["N1"]); 
        checkReverseContains("N11", ["N1"]);
        
        /***
        assertThat(reversed, contains{
            eqn("N", []), 
            eqn("N0", ["N"]), 
            eqn("N1", ["N"]), 
            eqn("N00", ["N0", "N1"]), 
            eqn("N01", ["N0"]), 
            eqn("N10", ["N1"]), 
            eqn("N11", ["N1"]) 
        });
        */
        //print("Reversed: ``reversed``");
        
    }
}