import ceylon.collection {
	ArrayList
}
import ceylon.language.meta.model {
	Attribute,
	Method
}

shared alias FieldMatcher<Klass> given Klass satisfies Object => 
        <AttributeMatcher<Klass, Anything>> | 
        <IndirectAttributeMatcher<Klass, Anything, Anything>> | 
        <MethodMatcher<Klass, Object> >;




shared ObjectMatcherBuilder<Class> isObject<Class>(/*ClassModel<Class, Nothing> classModel,*/ Class expected) 
        given Class satisfies Object
        => ObjectMatcherBuilder<Class>(expected);



"Compound matcher, matches when all child matchers match."
by ("Jean-Pierre Ragey")
shared class ObjectMatcher<Class> (
    "Children matchers"
    FieldMatcher<Class>* children
) 
        satisfies Matcher<Class> 
        given Class satisfies Object
{
            
    
    shared actual Boolean match(Anything actual) {
        for(m in children) {
            if(!m.match(actual)) {
                return false;
            }
        }
        return true;
    }
    
    shared actual Description explainFully(Anything actual, Descriptor descriptor) {
        value matcherNb = children.size;
        value sb = ArrayList<Description>();
        variable Integer matchCount = 0;
        
        for(m in children) {
            Boolean matched = m.match(actual);
            if(matched) {
                matchCount++;
            }
            Description childDescr = m.explainFully(actual, descriptor);
            sb.add(childDescr);
        }
        Boolean allMatched = (matcherNb == matchCount);
        return Description{
            explain = allMatched
                then "`` `Class` `` matched"
                else "`` `Class` `` mismatched";
            highlight = allMatched then noHighlight else errorHighlight;
            children = sb.sequence();
        };
    }
    
    
    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        textBuilder.appendValue(actual else "<null>");
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("`` `Class` `` ")
                .appendList("{", ", ", "}", children);
    }
    
    
}

//shared alias AttributeOrMethod<Class, out Field> => Attribute<Class, Field?, Nothing>|Method<Class, Field?, []>;
//
//Field? callAttributeOrMethod<Class, out Field>(
//    AttributeOrMethod<Class, Field> 
//            attribute,
//    Class obj
//) 
//        given Class satisfies Object
//        given Field satisfies Object
//{
//    switch(attribute)
//    case(is Attribute<Class, Field?, Nothing>) {return attribute.bind(obj).get();}
//    case(is Method<Class, Field? , []>) {return attribute.bind(obj)();}
//}

shared Field? callAttribute<Class, out Field>(Attribute<Class, Field, Nothing> attribute, Class obj) 
        given Class satisfies Object
{
     return attribute.bind(obj).get();
}

Field? getAttribute<Class, Field>(Class obj, Attribute<Class, Field?, Nothing> attribute)
        given Class satisfies Object
{
    Field? result = attribute.bind(obj).get();
    return result;
}

//shared AttributeMatcher<Klass, Field> attributeMatcher<Klass, out Field>(
// 
//    Matcher<Field> attrMatcher, 
//    Attribute<Klass, Field?> attribute,
//    Field? (Klass ) attr = (Klass obj) => getAttribute(obj, attribute)
//) given Klass satisfies Object
//        => AttributeMatcher(attrMatcher, attribute, attr);
//
shared final class AttributeMatcher<Klass, out Field>(
    Matcher<Field> attrMatcher, 
    //Attribute<Klass, Field?, Nothing> |<Field? (Klass)> attribute
    Attribute<Klass, Field?, Nothing> attribute
    //Attribute<Klass, RawField, Nothing> attribute
    
    ,
    //Field? attr(Klass obj)  // => getAttribute(obj, attribute) // TODO : check backend error
    //, shared Field fieldConvert(RawField r)
    //Field attr(Klass obj) => fieldConvert(attribute.bind(obj).get())
    Field? attr(Klass obj) => attribute.bind(obj).get()
) satisfies TypeSafeCombinableMatcher<Klass>
        given Klass satisfies Object
        //given Field satisfies Object
{
    //Field? attr(Klass obj) => attribute.bind(obj).get();
    
    
    shared actual Boolean typeSafeMatch(Klass actual) => attrMatcher.match(attr(actual));

    shared actual Description typeSafeExplainFully(Klass actual, Descriptor descriptor) {
        return Description("``attribute.declaration.name``: ", [attrMatcher.explainFully(attr(actual), descriptor)]);
    }

    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("`` attribute.declaration.name ``: ") 
                .appendDescriptionOf(attrMatcher);
    }
    
    shared actual void typeSafeDescribeActual(Klass actual, TextBuilder textBuilder) {
        textBuilder .appendText("Field[")
                    .appendValue(actual)
                    .appendText("]");
    }
}

shared class IndirectAttributeMatcher<Klass, out Field, out RawField>(
    Matcher<Field> attrMatcher, 
    Attribute<Klass, RawField, Nothing> attribute, 
    Field fieldConvert(RawField r)
) satisfies TypeSafeCombinableMatcher<Klass>
        given Klass satisfies Object
{
    Field? attr(Klass obj) => fieldConvert(attribute.bind(obj).get());
    
    
    shared actual Boolean typeSafeMatch(Klass actual) => attrMatcher.match(attr(actual));

    shared actual Description typeSafeExplainFully(Klass actual, Descriptor descriptor) {
        return Description("``attribute.declaration.name``: ", [attrMatcher.explainFully(attr(actual), descriptor)]);
    }

    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("`` attribute.declaration.name ``: ") 
                .appendDescriptionOf(attrMatcher);
    }
    
    shared actual void typeSafeDescribeActual(Klass actual, TextBuilder textBuilder) {
        textBuilder .appendText("Field[")
                    .appendValue(actual)
                    .appendText("]");
    }
}














shared class MethodMatcher<Class, out Field>(
    Matcher<Field> attrMatcher, 
    //Field? attr(Class obj),
    //AttributeOrMethod<Class, Field> attribute
    //Attribute<Class, Field?, Nothing>|Method<Class, Field?, []> attribute
    Method<Class, Field?, Nothing> attribute,
    Field? attr(Class obj)
    
    //Get attributeOf<Container, Get>(Attribute<Container, Get, Nothing> attribute, Country country) {
    //    Get result = attribute.bind(country).get();
    //    return result;
    //}
    
    
) satisfies TypeSafeCombinableMatcher<Class>
        given Class satisfies Object
        //given Field satisfies Object
{
    shared actual Boolean typeSafeMatch(Class actual) => attrMatcher.match(attr(actual));
    
    shared actual Description typeSafeExplainFully(Class actual, Descriptor descriptor) {
        return Description("``attribute.declaration.name``: ", [attrMatcher.explainFully(attr(actual), descriptor)]);
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("`` attribute.declaration.name ``: ") 
                .appendDescriptionOf(attrMatcher);
    }
    
    shared actual void typeSafeDescribeActual(Class actual, TextBuilder textBuilder) {
        textBuilder .appendText("Field[")
                .appendValue(actual)
                .appendText("]");
    }
}
