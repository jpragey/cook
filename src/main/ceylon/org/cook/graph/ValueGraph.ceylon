
shared class ValueNodeWrapper<Node>(shared actual Node node)
        satisfies NodeWrapper<Node> 
        given Node satisfies Object 
{
    shared actual Integer hash => node.hash;
    
    shared actual Boolean equals(Object that) {
        if(is ValueNodeWrapper<Node> that) {
            return that.node == this.node;
        }
        return false;
    }
    shared actual String string => "VNW(``node``:``hash``)";
}

shared class ValueGraph<Node>(
    {Node *} initialNodes,
    shared [Node *] dependencies(Node node),
    ""
    DependenciesCheck checkDependencies = includeDeps
) 
        extends AbstractGraph<Node, ValueNodeWrapper<Node>>(
    (Node node) => ValueNodeWrapper(node),
    initialNodes, 
    dependencies, 
    checkDependencies
)
        given Node satisfies Object 
{
}
