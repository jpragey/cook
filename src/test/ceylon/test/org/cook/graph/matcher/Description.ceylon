
shared class Description(explain = null, children = [], highlight = noHighlight) 
{
    shared String? explain;
    shared [Description *] children;
    shared Highlight highlight;
    
    
    Boolean explainEquals(Description that) {
        if(is String explain, is String thatExplain = that.explain) {
            return explain == thatExplain;
        }
        return (explain is Null) && (that.explain is Null);
    }
    shared actual Boolean equals(Object that) {
        if(is Description that){
            return explainEquals(that) && children.equals(that.children) && highlight === that.highlight;
        } else {
            return false;
        }
    }
    
    shared actual String string => "Description (\"``explain else "<null>"``\", {`` ", ".join{for(c in children) c.string} ``}, ``highlight``)";
    
    shared default void dumpDescription(Anything(String, Integer) indentedPrint, Integer indentCount = 0) {
        Integer childIndent;
        if(exists explain ) {
            indentedPrint(explain, indentCount);
            childIndent = indentCount + 1;
        } else {
            childIndent = indentCount;
        }
        for(child in children) {
            child.dumpDescription(indentedPrint, childIndent);
        }
    }
    
    shared ExplainNode toExplainNode() => ExplainNode(explain, {for(c in children) c.toExplainNode()});
}



shared class ExplainNode(shared String? msg, {ExplainNode *} children) {
    Integer extraCharsCount = ( msg exists) then 3 else 0;
    Integer extraCharsPerChild = 2;
    shared Integer singleLineSize = sum {
        msg?.size else 0,
        extraCharsCount, 
        children.size * extraCharsPerChild, 
        *children*.singleLineSize
    };
    
    shared void dumpAsSingleLine(StringBuilder sb) {
        if(exists msg) {
            sb.append(msg);
            if(! children.empty) {
                sb.append(" (");
            }
        }
        variable Boolean first = true;
        for(c in children) {
            c.dumpAsSingleLine(sb);
            if(first) {
                sb.append(", ");
                first = false;
            }
        }
        if(exists msg, ! children.empty) {
            sb.append(")");
        }
    }
    
    shared void dumpDescription(Anything(String, Integer) indentedPrint, Integer lineSizeLimit, Integer indentCount = 0) {
        if(singleLineSize <= lineSizeLimit) {
            StringBuilder sb = StringBuilder(); 
            dumpAsSingleLine(sb);
            String line = sb.string;
            indentedPrint(line, indentCount);
        } else {
            Integer childIndent;
            if(exists msg) {
                indentedPrint(msg, indentCount);
                childIndent = indentCount + 1;
            } else {
                childIndent = indentCount;
            }
            children*.dumpDescription(indentedPrint, lineSizeLimit, childIndent);
            
        }
    }
}



