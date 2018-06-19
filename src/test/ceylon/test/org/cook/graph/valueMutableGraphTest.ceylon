


class ValueMutableGraphTest() {
/***
    LinkedList<N> safeGet<N>(N key, Map<N, LinkedList<N>> map) given N satisfies Object {
        //if(res = exists map.get(map)) {
        //    
        //}
        assert (exists res = map.get(key) );
        return res;
    }
    
    class IntGraph({Integer *} nodes, Map<Integer, LinkedList<Integer>> deps) 
            extends ValueGraph<Integer>(nodes, (Integer node) 
            => safeGet(node, deps).sequence()) 
        {}
    Matcher<Anything> isInts({Integer *} expected) => contains{ for(n in expected) eq(n) };

    class FloatGraph({Float *} nodes, Map<Float, LinkedList<Float>> deps) 
            extends ValueGraph<Float>(nodes, (Float node) 
            => safeGet(node, deps).sequence()) 
    {}

    Matcher<Anything> isFloats({Float *} expected) => contains{ for(n in expected) eq(n) };

    "Match name and first-level dependencies names"
    Matcher<Cycle<Integer>> isIntCycle(Cycle<Integer> expected) {
        return ObjectMatcher<Cycle<Integer>>(
            AttributeMatcher(contains{for(i in expected.nodes) eq(i)}, `Cycle<Integer>.nodes`)
        );
    }
    
    interface Fixture {
        shared formal IntGraph initialGraph;
        shared formal Matcher<Anything> acyclicCopyResponse; 
        shared formal Matcher<Anything> cyclicCopyResponse;
        shared formal Matcher<Anything> sortedGraphResponse;
    }
    
    class FixtureWithCycle() satisfies Fixture {
        value initialGraphDeps = HashMap<Integer, LinkedList<Integer>> {
            0 ->LinkedList{1},    // cycle 0->1->2->0
            1 ->LinkedList{2},
            2 ->LinkedList{0, 4},
            3 ->LinkedList<Integer>{},
            4 ->LinkedList{5},
            5 ->LinkedList<Integer>{}
        };

        shared actual IntGraph initialGraph = IntGraph({0, 1, 2, 3, 4, 5}, initialGraphDeps);
        
        shared actual Matcher<Anything> acyclicCopyResponse = isIntCycle(Cycle{0, 1, 2}); 
        shared actual Matcher<Anything> sortedGraphResponse = isIntCycle(Cycle{0, 1, 2});
        
        value copiedGraphDeps = HashMap<Float, LinkedList<Float>> {
            0.0 ->LinkedList{1.0},    // cycle 0->1->2->0
            1.0 ->LinkedList{2.0},
            2.0 ->LinkedList{0.0, 4.0},
            3.0 ->LinkedList<Float>{},
            4.0 ->LinkedList{5.0},
            5.0 ->LinkedList<Float>{}
        };
        shared FloatGraph copiedGraph = FloatGraph({0.0, 1.0, 2.0, 3.0, 4.0, 5.0}, copiedGraphDeps);
        shared actual Matcher<Anything> cyclicCopyResponse = contains{eq(0.0), eq(1.0), eq(2.0), eq(3.0), eq(4.0), eq(5.0)};
        
    }
    
    class AcyclicFixture0() satisfies Fixture {
        
        shared actual IntGraph initialGraph = IntGraph(
            {0, 1, 2}, 
            HashMap<Integer, LinkedList<Integer>> {
                0 ->LinkedList<Integer>{},
                1 ->LinkedList{0},
                2 ->LinkedList{1}
            });
            
        FloatGraph copiedGraph = FloatGraph(
            {0.0, 1.0, 2.0}, 
            HashMap<Float, LinkedList<Float>> {
                0.0 ->LinkedList<Float>{},
                1.0 ->LinkedList{0.0},
                2.0 ->LinkedList{1.0}
            });

        shared actual Matcher<Anything> acyclicCopyResponse = isFloats(copiedGraph.nodes); 
        shared actual Matcher<Anything> cyclicCopyResponse = isFloats(copiedGraph.nodes);
        
        IntGraph sortedGraph = IntGraph(
            {0, 1, 2}, 
            HashMap<Integer, LinkedList<Integer>> {
                0 ->LinkedList<Integer>{},
                1 ->LinkedList{0},
                2 ->LinkedList{1}
            });
        shared actual Matcher<Anything> sortedGraphResponse => isInts(sortedGraph.nodes);
    }
    
    class AcyclicFixture() satisfies Fixture {

        shared actual IntGraph initialGraph = IntGraph(
            {0, 1, 2, 3, 4, 5}, 
            HashMap<Integer, LinkedList<Integer>> {
                0 ->LinkedList{1, 2},
                1 ->LinkedList{2},
                2 ->LinkedList{4},
                3 ->LinkedList<Integer>{},
                4 ->LinkedList{3},
                5 ->LinkedList<Integer>{}
            });

        FloatGraph copiedGraph = FloatGraph(
            {0.0, 1.0, 2.0, 3.0, 4.0, 5.0}, 
            HashMap<Float, LinkedList<Float>> {
                0.0 ->LinkedList{1.0, 2.0},
                1.0 ->LinkedList{2.0},
                2.0 ->LinkedList{4.0},
                3.0 ->LinkedList<Float>{},
                4.0 ->LinkedList{3.0},
                5.0 ->LinkedList<Float>{}
            });
        
        shared actual Matcher<Anything> acyclicCopyResponse = isFloats(copiedGraph.nodes); 
        shared actual Matcher<Anything> cyclicCopyResponse = isFloats(copiedGraph.nodes);

        IntGraph sortedGraph = IntGraph(
            {3, 5, 4, 2, 1, 0}, 
            HashMap<Integer, LinkedList<Integer>> {
                0 ->LinkedList{1, 2},
                1 ->LinkedList{2},
                2 ->LinkedList{4},
                3 ->LinkedList<Integer>{},
                4 ->LinkedList{3},
                5 ->LinkedList<Integer>{}
            });
        shared actual Matcher<Anything> sortedGraphResponse => isInts(sortedGraph.nodes);
    }
    
    test shared void copyGraphTest() {
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
    
        value targetGraphDeps = HashMap<Float, LinkedList<Float>>();
        Float createNode(Integer node, [Float *] deps) {
            Float result = node.float;
            
            assert (! targetGraphDeps.get(result) exists);
            targetGraphDeps.put(result, LinkedList<Float>( deps ));
            
            return result;
        }
        
        // -- Test acyclic copy
        Float[]|Cycle<Integer> targetGraph = fixture.initialGraph.copyAcyclic {
            createNode = createNode;
            explainCycle = true;
            keepNodesOrder = true;
        };
        //print("targetAcyclicGraph: ``targetGraph``");
        assertThat(targetGraph, fixture.acyclicCopyResponse);
    }
    
    void copyCyclic(Fixture fixture) {
        
        value targetGraphDeps = HashMap<Float, LinkedList<Float>>();
        Float createNode(Integer node/*, [Float *] deps*/) {
            Float result = node.float;
            return result;
        }
        void addDependency(Float container, Float dep) {
            //assert (! targetGraphDeps.get(container) exists);
            if(exists deps =  targetGraphDeps.get(container)) {
                deps.add(dep);
            } else {
                targetGraphDeps.put(container, LinkedList<Float>{dep});
            }
        }
        
        // -- Test cyclic copy
        Float[] targetCyclicGraph = fixture.initialGraph.copyCyclic(createNode, addDependency);
        
        //print("targetCyclicGraph: ``targetCyclicGraph``"); 
        assertThat(targetCyclicGraph, fixture.cyclicCopyResponse);
        
    }
    
    void graphSort(Fixture fixture) {
        
        // -- Test cyclic copy
        <Integer[] | Cycle<Integer>> sortedGraph = fixture.initialGraph.sort{showCycle = true;};
        
        //print("sortedGraph: ``sortedGraph``"); 
        assertThat(sortedGraph, fixture.sortedGraphResponse);
        
    }
    */
}

