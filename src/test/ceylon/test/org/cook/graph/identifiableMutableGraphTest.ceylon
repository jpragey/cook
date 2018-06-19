import ceylon.collection {
	LinkedList
}
import org.cook.graph {
	IdentifiableGraph,
	Cycle
}
import ceylon.test {
	assertFalse,
	test
}
import test.org.cook.graph.matcher {
	assertThat,
	Matcher,
	ObjectMatcher,
	AttributeMatcher,
	eq,
	contains
}



class IdentifiableMutableGraphTest() {

    interface MNode<N> satisfies Identifiable given N satisfies MNode<N> {
        shared formal String className;
        shared formal String name;
        shared formal LinkedList<N> dependencies;
        shared actual String string => "``className``(``name``=>``{for(d in dependencies) d.name}``)";
    } 
    
    class NodeGraph<N>({N*} nodes) extends IdentifiableGraph<N>(nodes, (N node) => node.dependencies.sequence()) 
        given N satisfies MNode<N> {}

    "Match name and first-level dependencies names"
    Matcher<MNode<N>> isNode<N>(MNode<N> expected/*String nodeName, [String *] depNames*/)
            given N satisfies MNode<N> 
    {
        return ObjectMatcher<MNode<N>>(
            AttributeMatcher(eq(expected.name), `MNode<N>.name`),
            AttributeMatcher(contains({for(dn in expected.dependencies) eq(dn.name)} ), `MNode<N>.dependencies`, (MNode<N> obj) => {for(d in obj.dependencies)d.name} )
        );
    }
    Matcher<Anything> isNodes<N>({<MNode<N>> *} expected) given N satisfies MNode<N> => contains{ for(n in expected) isNode(n) };


    //"Match name and first-level dependencies names"
    //Matcher<Cycle<Node<N>>> isCycle<N>(Cycle<N> expected) given N satisfies Node<N> {
    //    return ObjectMatcher<Cycle<Node<N>>>(
    //        AttributeMatcher(isNodes(expected.nodes), `Cycle<Node<N>>.nodes`, (Cycle<Node<N>> obj) => obj.nodes)
    //    );
    //}

    
    // -- MNode
    
    class MNode0(shared actual String name, shared actual LinkedList<MNode0> dependencies = LinkedList<MNode0>()) satisfies MNode<MNode0> {
        shared actual String className = "MNode";
    }
    "Match name and first-level dependencies names"
    Matcher<Cycle<MNode0>> isMNodeCycle(Cycle<MNode0> expected) {
        return ObjectMatcher<Cycle<MNode0>>(
            AttributeMatcher(isNodes(expected.nodes), `Cycle<MNode0>.nodes`)
        );
    }
    
    // -- MNode
    class MNode1(shared actual String name, shared actual LinkedList<MNode1> dependencies = LinkedList<MNode1>())
            satisfies MNode<MNode1> 
    {
        shared actual String className = "MNode1";
    }
    
    interface Fixture {
        shared formal NodeGraph<MNode0> initialGraph;
        shared formal Matcher<Anything> acyclicCopyResponse; 
        shared formal Matcher<Anything> cyclicCopyResponse;
        shared formal Matcher<Anything> sortedGraphResponse;
        
    }
    
    class FixtureWithCycle() satisfies Fixture {
        shared actual NodeGraph<MNode0> initialGraph  {
            MNode0 node000 = MNode0("N000");
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01");
            MNode0 node02 = MNode0("N02");
            MNode0 node1 = MNode0("N1", LinkedList<MNode0>{node00, node01} );
            
            // Create cycle
            node00.dependencies.add(node01);
            node01.dependencies.add(node02);
            node02.dependencies.add(node00);
            
            return NodeGraph<MNode0>({node000, node00, node01, node02, node1});
        }
        
        Cycle<MNode0> cycle  {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01");
            MNode0 node02 = MNode0("N02");
            
            // Create cycle
            node00.dependencies.add(node01);
            node01.dependencies.add(node02);
            node02.dependencies.add(node00);
            
            return Cycle ([ node00, node01, node02 ]);
        }
        shared actual Matcher<Anything> acyclicCopyResponse = isMNodeCycle(cycle); 
        shared actual Matcher<Anything> sortedGraphResponse = isMNodeCycle(cycle);
        
        NodeGraph<MNode1> copiedGraph  {
            MNode1 node000 = MNode1("N000");
            MNode1 node00 = MNode1("N00");
            MNode1 node01 = MNode1("N01");
            MNode1 node02 = MNode1("N02");
            MNode1 node1 = MNode1("N1", LinkedList<MNode1>{node00, node01} );
            
            // Create cycle
            node00.dependencies.add(node01);
            node01.dependencies.add(node02);
            node02.dependencies.add(node00);
            
            return NodeGraph<MNode1>({node000, node00, node01, node02, node1});
        }
        shared actual Matcher<Anything> cyclicCopyResponse = isNodes(copiedGraph.nodes);
        
    }
    
    class AcyclicFixture0() satisfies Fixture {
        shared actual NodeGraph<MNode0> initialGraph  {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node01});
            
            return NodeGraph({node00, node01, node02});
        }
        
        NodeGraph<MNode0> sortedGraph  {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node01});
            
            return NodeGraph({node00, node01, node02});
        }
        shared actual Matcher<Anything> sortedGraphResponse => isNodes(sortedGraph.nodes);
        
        NodeGraph<MNode1> copiedGraph  {
            MNode1 node00 = MNode1("N00");
            MNode1 node01 = MNode1("N01", LinkedList{node00});
            MNode1 node02 = MNode1("N02", LinkedList{node01});
            
            return NodeGraph({node00, node01, node02});
        }
        shared actual Matcher<Anything> acyclicCopyResponse = isNodes(copiedGraph.nodes); 
        shared actual Matcher<Anything> cyclicCopyResponse = isNodes(copiedGraph.nodes);
        
    }
    
    class AcyclicFixture() satisfies Fixture {
        
        shared actual NodeGraph<MNode0> initialGraph  {
            MNode0 node000 = MNode0("N000");
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01");
            MNode0 node02 = MNode0("N02");
            MNode0 node1 = MNode0("N1", LinkedList<MNode0>{node00, node01} );
            
            // Create cycle
            node00.dependencies.add(node01);
            node01.dependencies.add(node02);
            //node02.dependencies.add(node00);
            
            return NodeGraph<MNode0>({node000, node00, node01, node02, node1});
        }
        
        NodeGraph<MNode0> sortedGraph  {
            MNode0 node000 = MNode0("N000");
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01");
            MNode0 node02 = MNode0("N02");
            MNode0 node1 = MNode0("N1", LinkedList<MNode0>{node00, node01} );
            
            // Create cycle
            node00.dependencies.add(node01);
            node01.dependencies.add(node02);
            
            return NodeGraph({node000, node02, node01, node00, node1});
        }
        //shared actual Matcher<Anything> sortedGraphResponse => isNodes(sortedGraph.nodes);
        shared actual Matcher<Anything> sortedGraphResponse => isNodes(sortedGraph.nodes);
        
        NodeGraph<MNode1> copiedGraph  {
            MNode1 node000 = MNode1("N000");
            MNode1 node00 = MNode1("N00");
            MNode1 node01 = MNode1("N01");
            MNode1 node02 = MNode1("N02");
            MNode1 node1 = MNode1("N1", LinkedList<MNode1>{node00, node01} );
            
            // Create cycle
            node00.dependencies.add(node01);
            node01.dependencies.add(node02);
            //node02.dependencies.add(node00);
            
            return NodeGraph<MNode1>({node000, node00, node01, node02, node1});
        }
        shared actual Matcher<Anything> acyclicCopyResponse = isNodes(copiedGraph.nodes); 
        shared actual Matcher<Anything> cyclicCopyResponse = isNodes(copiedGraph.nodes);
        
    }
    
    test shared void allGraphTest() {
        {Fixture *} fixtures = {
            FixtureWithCycle(),
            AcyclicFixture0(),
            AcyclicFixture()
        };
        for(f in fixtures) {
            //print("sourceGraph: ``f.initialGraph``");
            copyAcyclic(f);
            copyCyclic(f);
            graphSort(f);
        }
    }
        
    void copyAcyclic(Fixture fixture) {
        
        // -- Test acyclic copy
        MNode1[]|Cycle<MNode0> targetGraph = fixture.initialGraph.copyAcyclic {
            createNode = (MNode0 node, [MNode1 *] deps) => MNode1(node.name, LinkedList<MNode1>(deps));
            explainCycle = true;
            keepNodesOrder = true;
        };
        //print("targetAcyclicGraph: ``targetGraph``");
        assertThat(targetGraph, fixture.acyclicCopyResponse);
    }
    
    void copyCyclic(Fixture fixture) {
        
        // -- Test cyclic copy
        MNode1[] targetCyclicGraph = fixture.initialGraph.copyCyclic(
            (MNode0 node) => MNode1(node.name),
            (MNode1 container, MNode1 dep) => container.dependencies.add(dep)
        );
        
        //print("targetCyclicGraph: ``targetCyclicGraph``"); 
        assertThat(targetCyclicGraph, fixture.cyclicCopyResponse);
        
    }
    void graphSort(Fixture fixture) {
        
        // -- Test cyclic copy
        MNode0[]|Cycle<MNode0> sortedGraph = fixture.initialGraph.sort{showCycle = true; keepNodesOrder = true;};
        
        //print("sortedGraph: ``sortedGraph``"); 
        assertThat(sortedGraph, fixture.sortedGraphResponse);
        
    }
    
    test shared void equalGraphTest() {
        
        NodeGraph<MNode0> initialGraph  {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node01});
            
            return NodeGraph({node00, node01, node02});
        }
        Boolean shallowCompare(MNode0 thisNode, MNode0 thatNode) => thisNode.name == thatNode.name;
        
//        assertTrue(initialGraph.equalGraph(initialGraph, shallowCompare));
//
//        // --
//        NodeGraph<MNode0> sameGraph {
//            MNode0 node00 = MNode0("N00");
//            MNode0 node01 = MNode0("N01", LinkedList{node00});
//            MNode0 node02 = MNode0("N02", LinkedList{node01});
//            
//            return NodeGraph({node00, node01, node02});
//        }
//        assertTrue(initialGraph.equalGraph(sameGraph, shallowCompare));

        // --
        NodeGraph<MNode0> graphWithShallowMismatching {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("oops", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node01});
            
            return NodeGraph({node00, node01, node02});
        }
        assertFalse(initialGraph.equalGraph(graphWithShallowMismatching, shallowCompare));
        
        // --
        NodeGraph<MNode0> graphWithDifferentNodeCount {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node01});
            MNode0 nodeExtra = MNode0("extra");
            
            return NodeGraph({node00, node01, node02, nodeExtra});
        }
        assertFalse(initialGraph.equalGraph(graphWithDifferentNodeCount, shallowCompare));
        
        // --
        NodeGraph<MNode0> graphWithDifferentDepCount {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node01, node00/*extra*/});
            
            return NodeGraph({node00, node01, node02});
        }
        assertFalse(initialGraph.equalGraph(graphWithDifferentDepCount, shallowCompare));
        
        // --
        NodeGraph<MNode0> graphWithDifferentDeps {
            MNode0 node00 = MNode0("N00");
            MNode0 node01 = MNode0("N01", LinkedList{node00});
            MNode0 node02 = MNode0("N02", LinkedList{node00 /*instead of node01*/});
            
            return NodeGraph({node00, node01, node02});
        }
        assertFalse(initialGraph.equalGraph(graphWithDifferentDeps, shallowCompare));
        
    }

}
