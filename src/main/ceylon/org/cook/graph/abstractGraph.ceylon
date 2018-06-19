import ceylon.collection { HashMap, LinkedList, HashSet, ArrayList }


shared interface NodeWrapper<Node> {
    shared formal Node node;
}

shared class AbstractGraph<Node, NW>(
    NW wrapNode(Node node),
    shared {Node *} initialNodes,
    shared actual [Node *] dependencies_(Node node),
    ""
    DependenciesCheck checkDependencies = dontCheckMissingDep
) 
        satisfies Graph<Node> 
        given Node satisfies Object 
        given NW satisfies NodeWrapper<Node> 
{
    shared actual {Node *} nodes;
    
    switch(checkDependencies)
    case (dontCheckMissingDep) {
        nodes = initialNodes;
    }
    case (includeDeps) {
        LinkedList<NW> currentWrappers = LinkedList<NW>{for(n in initialNodes) wrapNode(n)} ;
        HashSet<NW> nodeWrappers = HashSet<NW>{*currentWrappers};
        value sb = ArrayList<Node>();
        
        while(exists wrapper = currentWrappers.deleteFirst()) {
            Node node = wrapper.node;
            sb.add(node);
            
            for(depNode in dependencies_(node)) {
                value depNodeWrapper = wrapNode(depNode);
                //Boolean depNodeExists = nodeWrappers.contains(depNodeWrapper);
                //print("DepNode ``depNode`` exists: ``depNodeExists``");
                if(! nodeWrappers.contains(depNodeWrapper)) {
                    currentWrappers.add(depNodeWrapper);
                }
                // TODO: bug in behaviour of next line
                //Boolean depNodeExists = nodeWrappers.add(depNodeWrapper);
                //print("DepNode ``depNode`` exists: ``depNodeExists``");
                //if(! depNodeExists) {
                //    currentWrappers.add(depNodeWrapper);
                //}
            }
        }
        nodes = sb.sequence();
    }
    case (throwIfMissingDep) {
        [NW *] currentWrappers = {for(n in initialNodes) wrapNode(n)}.sequence();
        //Array<NW> currentWrappers = Array<NW>(currentWrapperIt) ;
        HashSet<NW> nodeWrappers = HashSet<NW>{*currentWrappers};
        
        for(w in currentWrappers) {
            for(depNode in dependencies_(w.node)) {
                value depNodeWrapper = wrapNode(depNode);
                if(! nodeWrappers.contains(depNodeWrapper)) {
                    throw GraphException("Dependency node ``depNode.string`` does not belong to nodes ``initialNodes``");
                }
            }
        }
        nodes = initialNodes;
    }
    
    class TargetWrapper<TargetNode>(shared NodeWrapper<Node> key) given TargetNode satisfies Object {
        shared variable TargetNode? targetNode = null;
        shared variable Boolean cycleStart = false;
    }
    
    class MapWrapper<TargetNode>() given TargetNode satisfies Object {
        value copyMap = HashMap<NodeWrapper<Node>, TargetWrapper<TargetNode>> ();
        
        shared TargetWrapper<TargetNode>? copyExists (Node node) {
            value nw = wrapNode(node);
            TargetWrapper<TargetNode>? result = copyMap.get(nw);
            //print("Searching NodeWrapper ``nw`` in copyMap ``copyMap`` : found ``result else "(none)"``");
            return result;
        }
        shared TargetWrapper<TargetNode> put(Node node) {
            value key = wrapNode(node); 
            TargetWrapper<TargetNode> target = TargetWrapper<TargetNode>(key);
            copyMap.put(key, target);
            return target;//, 
            //
        }
        shared [TargetNode *] targetNodes {
            value sb = ArrayList<TargetNode>();
            for(wrapper in copyMap.items) {
                assert (exists target = wrapper.targetNode);
                sb.add(target);
            }
            return sb.sequence();
        }
        shared {<NodeWrapper<Node> -> TargetWrapper<TargetNode>> *} entries => copyMap;
        shared TargetNode getTargetNodeSafe(Node node) {
            assert (exists targetWrapper = copyMap.get(wrapNode(node))  );
            assert (exists res = targetWrapper.targetNode);
            return res;
        }
    }
    
    "Copy acyclic graph.
     Returns [[Cycle]] if a cycle is found."
    shared actual <TargetNode[]|Cycle<Node>> copyAcyclic<TargetNode>(
        TargetNode  (Node, [TargetNode *] ) createNode,
        Boolean explainCycle,
        Boolean keepNodesOrder
    )
            given TargetNode satisfies Object 
    {
        value copyMap = MapWrapper<TargetNode>();
        
        //print("copyValues: sourceNodes=``nodes``");
        
        // -- collect cycle elements
        value cycleListSb = ArrayList<TargetWrapper<TargetNode>> ();
        variable Boolean cycleStartFound = false;
        void appendToCycleList(TargetWrapper<TargetNode> w) {
            if(explainCycle) {
                if(!cycleStartFound) {
                    cycleListSb.add(w);
                } else if(w.cycleStart) {
                    cycleStartFound = true;
                }
            }
        }
        
        TargetNode? copyDeep(Node node) {   // null if a cycle is detected
            if(exists n1 = copyMap.copyExists(node)) {
                value targetNode = n1.targetNode; // null if there's a cycle
                if(! targetNode exists ) {
                    n1.cycleStart = true;
                }
                return targetNode;
            } else {
                value targetWrapper = copyMap.put(node);
                value sb = ArrayList<TargetNode>();
                for(dep in dependencies_(node)) {
                    if(exists TargetNode tn = copyDeep(dep)) {
                        sb.add(tn);
                    } else {
                        appendToCycleList(targetWrapper);
                        return null;    // cycle detected
                    }
                }
                TargetNode node1 = createNode(node, sb.sequence());
                targetWrapper.targetNode = node1;
                return node1;
            }
        }
        
        for(n in nodes) {
            if(! copyDeep(n) exists) {
                value cycle = Cycle<Node>(cycleListSb.reversed*.key*.node);
                return cycle; 
            }
        }
        TargetNode[] result = keepNodesOrder
        then {for(n in nodes) copyMap.getTargetNodeSafe(n) }.sequence()
        else copyMap.targetNodes;
        return result;
    }
    
    "Copy possibly cyclic graphs"
    shared actual TargetNode[] copyCyclic<TargetNode>(
        TargetNode createNode(Node original) ,
        Anything(TargetNode/*container*/, TargetNode/*dependency*/)appendDep
    )
            given TargetNode satisfies Object 
    {
        value copyMap = MapWrapper<TargetNode>();
        // -- create list
        value targetNodeSb = ArrayList<TargetNode>();
        for(n in nodes) {
            //TargetNode targetNode = createNode(n);
            TargetWrapper<TargetNode> tw = copyMap.put(n);
            value targetNode = createNode(n);
            targetNodeSb.add(targetNode);
            tw.targetNode = targetNode;
        }
        // append deps
        for(nodeWrapper -> targetWrapper in copyMap.entries) {
            Node node = nodeWrapper.node; 
            assert (exists tn = targetWrapper.targetNode);  // TODO: a targetWrapper with non-optional targetNode  
            
            for(dep in dependencies_(node)) {
                if(exists depTw = copyMap.copyExists(dep),  exists depTn = depTw.targetNode) {
                    appendDep(tn, depTn);
                }
            }
        }
        [TargetNode *] result = targetNodeSb.sequence();
        return result;
    }

    shared actual Boolean equalNodes({Node *} that, Boolean shallowMatch(Node thisNode, Node thatNode), [Node *] thatDependencies(Node node) ) 
    {
        if(nodes.size != that.size) {
            return false;
        }
        
        // TODO: use SDK [[zipPairs]], which currently bugs (backend error)
        {[F,S]*} zipPairs<F,S>({F*} firsts, {S*} seconds) {
            ArrayList<[F,S]> sb = ArrayList<[F,S]>();  
            Iterator<S> secondIt = seconds.iterator();
            for(f in firsts) {
                if(!is Finished s = secondIt.next()) {
                    sb.add([f, s]);
                }
            }
            return sb.sequence();
        }
        
        for([Node, Node] entry in zipPairs(nodes, that)) {
            Node thisNode = entry[0];
            Node thatNode = entry[1];
            // -- shallow match
            if(! shallowMatch(thisNode, thatNode)) {
                return false;
            }
            
            // -- match dependencies
            [Node *] thisDeps = dependencies_(thisNode);
            [Node *] thatDeps = dependencies_(thatNode);
            if(thisDeps.size != thatDeps.size) {
                return false;
            }
            
            for([Node, Node] depEntry in zipPairs(thisDeps, thatDeps)) {
                Node thisDep = depEntry [0];
                Node thatDep = depEntry [1];
                // -- shallow match
                if(! shallowMatch(thisDep, thatDep)) {
                    return false;
                }
            }
        }
        return true;
    }
    
    // TODO: ceylpon bug if it's local to [[sort]]
    class SortNode(shared Node node, [SortNode *] deps) {
        shared variable Integer edgeCount = 0;
        shared LinkedList<SortNode> dependents = LinkedList<SortNode>();
        shared LinkedList<SortNode> dependencies = LinkedList<SortNode>(deps);// for cycle detection
        
        shared actual String string => "G{``node`` -> ``dependents``}";
    }
    
    shared actual Cycle<Node>|[Node*] sort(Boolean showCycle, Boolean keepNodesOrder) {
        
        Cycle<Node>|SortNode[] gNodes = copyAcyclic((Node node, [SortNode *] deps) => SortNode(node, deps), showCycle, keepNodesOrder);
        switch(gNodes)
        case (is Cycle<Node>) {
            return gNodes;
        }
        case (is SortNode[]) {
            //dumpGraph2("GNodes (without dependents): ", IdentifiableGraph2(gNodes, (GNode node0) => node0.dependencies.sequence));
            
            for(gn in gNodes) {
                //print("-Adding dependents to ``gn`` dependencies");
                for(dep in gn.dependencies) {
                    dep.dependents.add(gn);
                    //print("--Adding dependent ``dep`` => ``gn`` ");
                }
                gn.edgeCount = gn.dependencies.size ;
            }
            //dumpGraph2("GNodes (with dependents): ", IdentifiableGraph2(gNodes, (GNode node0) => node0.dependencies.sequence));
            
            //for(node in gNodes) {
            //    print(" Edges: ``node`` = ``node.edgeCount`` edges");
            //}
            
            LinkedList<SortNode> processingNodes = LinkedList<SortNode> { for(n in gNodes) if(n.edgeCount == 0) n };
            LinkedList<SortNode> sortedNodes = LinkedList<SortNode>();
            LinkedList<SortNode> remainingNodes = LinkedList<SortNode>(gNodes);
            
            while(exists node = processingNodes.first) {
                processingNodes.remove(node);
                remainingNodes.remove(node);
                sortedNodes.add(node);
                
                for(dep in node.dependents) {
                    dep.edgeCount --;
                    if(dep.edgeCount == 0) {
                        processingNodes.add(dep);
                    }
                }
            }
            
            assert (remainingNodes.empty);
            //if(exists first = remainingNodes.first) {  // Cycle exists
            return {for(n in sortedNodes) n.node }.sequence() ;
        }
    }
    
    
    class ReverseWrapper<TargetNode>(shared Node node, shared [ReverseWrapper<TargetNode> *] edges) 
    {
        shared LinkedList<Node> reverseEdges = LinkedList<Node>(); 
    }
    
    shared actual <[TargetNode *]> | Cycle<Node> acyclicReverse<TargetNode>(
            TargetNode (Node/*original node*/, [Node *] /* new (reverse) dependencies*/) createNode,            
            Boolean explainCycle,
            Boolean keepNodesOrder
    ) 
    {
        //print("Original nodes: ``nodes``");
        value wrappers = copyAcyclic((Node node, [ReverseWrapper<TargetNode> *] edges) => ReverseWrapper(node, edges), explainCycle, keepNodesOrder );
        
        switch(wrappers)
        case (is ReverseWrapper<TargetNode>[]) {
            //print("Wrappers: `` {for(w in wrappers) w.node} ``");
            
            for(wn in wrappers) {
                for(edge in wn.edges) {
                    //print("  Append ``edge.node`` => ``wn.node``");
                    edge.reverseEdges.add(wn.node);
                }
            }
            
            value sb = ArrayList<TargetNode>();
            for(wn in wrappers) {
                Node[] reverseEdges = {for(rw in wn.reverseEdges) rw/*.node*/}.sequence();
                TargetNode newNode = createNode(wn.node, reverseEdges);
                sb.add(newNode);
            }
            return sb.sequence();
        }
        case (is Cycle<Node>) {
            return wrappers;
        }
    }   
}
