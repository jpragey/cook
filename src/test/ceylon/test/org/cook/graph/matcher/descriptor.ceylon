import ceylon.language.meta.model { Class, ClassModel }
import ceylon.language.meta { type }
import ceylon.collection { HashMap }

shared interface Descriptor {
    """Short description (to be included in 1-line description)"""
    shared formal String describe(Anything obj, Descriptor descriptor);
    
    """Long (tree) description"""
    shared formal Description describeFully(Anything obj, Descriptor descriptor);
    
    shared default SelfDescribing selfDescribing(Object? obj) {
        void describeTo0(TextBuilder textBuilder) {
            textBuilder.appendText(describe(obj, this));
        }
        object sd satisfies SelfDescribing {
            shared actual void describeTo(TextBuilder textBuilder) => describeTo0(textBuilder);
        }
        return sd;
    }
}

shared interface TypedDescriptor<T> satisfies Descriptor {
    shared actual String describe(Anything obj, Descriptor descriptor) {
        assert (is T obj);
        return tsDescribe(obj, descriptor);
    }
    
    """Long (tree) description"""
    shared actual Description describeFully(Anything obj, Descriptor descriptor) {
        assert (is T obj);
        return tsDescribeFully(obj, descriptor);
    }
    
    """Short description (to be included in 1-line description)"""
    shared formal String tsDescribe(T obj, Descriptor descriptor);
    
    """Long (tree) description"""
    shared formal Description tsDescribeFully(T obj, Descriptor descriptor);
}

""
shared class DefaultDescriptor(
    //shared String ? (Object?) delegate = (Object? obj) => null
    Map<Class<>, Descriptor> delegates = HashMap<Class<>, Descriptor>()
) satisfies Descriptor 
{
    Descriptor? findDelegate(Anything obj) {
        ClassModel<> cm = type(obj);
        Descriptor? d = delegates.get(cm);
        return d;
    }
    shared actual String describe(Anything obj, Descriptor descriptor) {
        if(exists d = findDelegate(obj)) {
            return d.describe(obj, descriptor);
        }
        
        if(is String obj) {
            return "\"" + obj.string + "\"";
        }
        
        if(is Iterable<Object> obj, !obj.empty) {
            return "[" +  (", ".join{for(o in obj) describe(o/*, descriptorEnv*/, descriptor)}) +"]";
        }
        
        return obj?.string else "<null>";
        
    }
    
    shared actual Description describeFully(Anything obj, Descriptor descriptor) {
        if(exists d = findDelegate(obj)) {
            Description descr = d.describeFully(obj, descriptor);
            return descr;
        }
        
        if(is String obj) {
            return Description("\"``obj``\"");
        }
        
        if(is Iterable<Object?> obj, !obj.empty) {
            return Description{
                children = [for(o in obj) describeFully(o, descriptor)];
            };
        }
        
        if(exists obj) {
            return Description(obj.string);
        } else {
            return Description("<null>");
        }
        
    }
    
}
