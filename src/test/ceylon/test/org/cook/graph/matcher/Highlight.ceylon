

shared abstract class Highlight() of noHighlight | errorHighlight {}
shared object noHighlight extends Highlight(){
    shared actual String string => "noHighlight";
}
shared object errorHighlight extends Highlight(){
    shared actual String string => "errorHighlight";
}
