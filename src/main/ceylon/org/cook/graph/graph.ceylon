

shared class GraphException(String message, Exception? cause = null) 
        extends Exception(message, cause) 
{
}

final shared class Cycle<Node>(shared Node [] nodes) {
    shared actual Boolean equals(Object that) {
        if(is Cycle<Node> that) {
            return that.nodes == nodes;
        }
        return false;
    }
    shared actual String string => "Cycle[``nodes``]";
}

""
shared interface Graph<Node> 
{
    "All nodes in graph"
    shared formal {Node *} nodes;

    "Total number of nodes in graph (typically shortcut for [nodes].size`)"
    shared default Integer size => nodes.size;
    
    "Get a node dependencies" 
    shared formal [Node *] dependencies_(Node node);
    //shared formal Boolean shallowEqualNode(Node node0, Node node1);
    
    "Topological sort of graph. If graph contains a cycle, a [[Cycle<Node>]] is returned. "
    shared formal Cycle<Node>|[Node*] sort(
        Boolean showCycle = false,
        Boolean keepNodesOrder = true
    );

    "Copy a graph, return a [[Cycle<Node>]] if a cycle is found.
     Note that not copying cycles allow node dependencies to be immutable."
    shared formal <TargetNode[]|Cycle<Node>> copyAcyclic<TargetNode>(
        "Create a node with its dependencies"
        TargetNode  createNode(Node original, [TargetNode *] dependencies) ,
        "When a cycle is found, if true, the returned cycle contains a cycle nodes; 
         if false, returns an empty [[Cycle]].
         Not computing cycle can be faster."
        Boolean explainCycle = true,
        Boolean keepNodesOrder = false
    ) given TargetNode satisfies Object ;
    
    "Copy a graph, including cycles. Note that target nodes must have mutable dependencies, 
     as there's no way to copy a cycle with immutable dependencies nodes (or at least I didn't find it)."    
    shared formal TargetNode[] copyCyclic<TargetNode>(
        "Create a node *without* dependencies"
        TargetNode createNode(Node original) ,
        "Append a dependency to an existing [[TargetNode]]"
        Anything appendDep(TargetNode container, TargetNode dependency)
        //, 
        //Boolean explainCycle = true
    ) given TargetNode satisfies Object;
    
    shared formal Boolean equalNodes(
        {Node *} that, 
        Boolean shallowMatch(Node thisNode, Node thatNode), 
        [Node *] thatDependencies(Node node) ); 

    shared default Boolean equalGraph(Graph<Node> that, Boolean shallowMatch(Node thisNode, Node thatNode)) =>  
            equalNodes {
        that = that.nodes;
        shallowMatch = shallowMatch;
        thatDependencies = that.dependencies_;
    };

    "Create a sequence of nodes with reverted edges.
     The grap is supposed to be acyclic, so TargetNode with immutable edges are OK.
     If a cycle is detected, a [[Cycle<Node>]] is returned. 
     "
    shared formal <[TargetNode *]> | Cycle<Node> acyclicReverse<TargetNode = Node>(
        "Create a [[TargetNode ]] from the original [[Node]] and its new dependencies."
        TargetNode (Node/*original node*/, [Node *] /* new (reverse) dependencies*/) createNode,
        "If a cycle is detected, its nodes are added to the returned Cycle; otherwise an emty Cycle is returned."            
        Boolean explainCycle = true,
        "If true, returned nodes are in the same order as graph [[nodes]]. 
         Otherwise returned node order is unpredictable."
        Boolean keepNodesOrder = true
    );

}



"Define how node dependencies must be handle when initializing a graph"
shared abstract class DependenciesCheck() of includeDeps | throwIfMissingDep | dontCheckMissingDep {}

"Include nodes dependencies in graph nodes"
shared object includeDeps extends DependenciesCheck() {}

"Throw a [[GraphException]] if a dependency doess''t belong to initial nodes list"
shared object throwIfMissingDep extends DependenciesCheck() {}

"Don't check dependencies and hope for the best (fast but dangerous)"
shared object dontCheckMissingDep extends DependenciesCheck() {}


 