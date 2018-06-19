

shared class IdentifiableNodeWrapper<Node>(shared actual Node node)
        satisfies NodeWrapper<Node> 
        given Node satisfies Identifiable 
{
    shared actual Integer hash => node.hash;
    
    shared actual Boolean equals(Object that) {
        if(is IdentifiableNodeWrapper<Node> that) {
            return that.node === this.node;
        }
        return false;
    }
    shared actual String string => "NW(``node``:``hash``)";
}


shared class IdentifiableGraph<Node>(
    {Node *} initialNodes,
    shared [Node *] (Node)dependencies,
    ""
    DependenciesCheck checkDependencies = includeDeps
) 
        extends AbstractGraph<Node, IdentifiableNodeWrapper<Node>>(
            (Node node) => IdentifiableNodeWrapper<Node>(node),
            initialNodes, 
            dependencies, 
            checkDependencies
)
        given Node satisfies Identifiable 
{
}
