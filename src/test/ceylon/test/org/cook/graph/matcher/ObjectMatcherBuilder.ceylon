import ceylon.language.meta.model {
    Method,
    Attribute
}
import ceylon.collection {
    ArrayList
}
shared class ObjectMatcherBuilder<Class>(
    Class expected
)
        satisfies MatcherFactory<Class> 
        given Class satisfies Object
{
    ArrayList<FieldMatcher<Class>> children = ArrayList<FieldMatcher<Class>>();
    
    shared actual ObjectMatcher<Class> get() => ObjectMatcher<Class>(*children);
    
    shared ObjectMatcherBuilder<Class> withAttributeMatcher<Field>(
        <AttributeMatcher<Class, Field> |
                <AttributeMatcher<Class, Field>(Class)> > attrMatcher
    ) {
        AttributeMatcher<Class, Field> m;
        switch(attrMatcher)
        case(is AttributeMatcher<Class, Field>) {m = attrMatcher;}
        case(is AttributeMatcher<Class, Field>(Class)) {m = attrMatcher(expected);}
        
        children.add(m);
        return this;
    }
    shared ObjectMatcherBuilder<Class> withAttribute<Field>(
        Attribute<Class, Field, Nothing> attribute,
        <Matcher<Field> | Matcher<Field>(Field)  > attrMatcher = eq<Field>(attribute(expected).get())
    ) {
        //        withAttributeMatcher(AttributeMatcher<Class, Field>(attrMatcher, attribute));
        Matcher<Field> m;
        //m = AttributeMatcher<Class, Field>(attrMatcher, attribute);
        //switch(attrMatcher)
        if (is Matcher<Field> attrMatcher) {m = attrMatcher;}
//        else if(is Matcher<Field>(Field) attrMatcher) {m = attrMatcher(attribute(expected).get() );}
        else {m = attrMatcher(attribute(expected).get() );}
        //else {
        //    throw AssertionError(
        //        "ObjectMatcherBuilder.withAttribute(): attrMatcher is expected to be a <Matcher<`` `Field` ``> | Matcher<`` `Field` ``>(`` `Class` ``)>, found `` attrMatcher `` ");
        //}
        
        children.add(AttributeMatcher<Class, Field>(m, attribute));
        
        return this;
    }
    
    shared ObjectMatcherBuilder<Class> withAttributes<Field>(
        Attribute<Class, Field, Nothing> * attributes
    ) 
    {
        for(a in attributes) {
            withAttribute(a);
        }
        return this;
    }
    
    shared ObjectMatcherBuilder<Class> withMethodMatcher<Field> (
        MethodMatcher<Class, Field> attrMatcher
    ) 
            given Field satisfies Object 
    {
        children.add(attrMatcher);
        return this;
    }
    
    shared ObjectMatcherBuilder<Class> withMethod<Field>(
        Matcher<Field> attrMatcher, 
        Method<Class, Field?, Nothing> attribute,
        Field? attr(Class obj)
    ) 
            given Field satisfies Object 
            => withMethodMatcher(MethodMatcher<Class, Field>(attrMatcher, attribute, attr));
    
    
    
    ObjectMatcherBuilder<Class> withAttributesInternal<Element> (
        <Attribute<Class, {Element *}, Nothing> /*|<{Element *} (Class)>*/ > attribute,
        {Element *} expected,
        Matcher<Element>(Element) matcherFactory,
        Descriptor descriptor,
        Matcher<{Element *}> iterableCompare({Matcher<Element> *} ms, Descriptor descriptor )
        // ,
        //{Element *} attr (Class cls)
        
    ) 
    //given Element satisfies Object 
    {
        {Matcher<Element> *} ms = {for(e in expected) matcherFactory(e) };
        Matcher<{Element *}> matcher = iterableCompare(ms, descriptor);
        
        value attrMatcher = AttributeMatcher<Class, {Element? *}>(matcher, attribute);
        children.add(attrMatcher);
        
        return this;
    }
    
    shared ObjectMatcherBuilder<Class> withIterableAttributeInAnyOrder<Element> (
        Attribute<Class, {Element *}, Nothing> attribute,
        //{Element *} expected,
        Matcher<Element>(Element) matcherFactory = eq<Element>,
        Descriptor descriptor = DefaultDescriptor(),
        Matcher<{Element *}> iterableCompare({Matcher<Element > *} ms, Descriptor descriptor) => 
                ContainsInAnyOrderMatcher<Element>(ms, descriptor)
        //,
        //{Element *} attr(Class obj) => attribute.bind(obj).get()
    ) 
    //given Element satisfies Object
            => withAttributesInternal( attribute, attribute(expected).get(), matcherFactory, descriptor, ContainsInAnyOrderMatcher<Element>); 
    
    shared ObjectMatcherBuilder<Class> withIterableAttribute<Element> (
        Attribute<Class, {Element *}, Nothing> attribute,
        //{Element *} expected,
        Matcher<Element>(Element) matcherFactory = eq<Element>,
        Descriptor descriptor = DefaultDescriptor(),
        Matcher<{Element *}> iterableCompare({Matcher<Element > *} ms, Descriptor descriptor) => 
                ContainsInAnyOrderMatcher<Element>(ms, descriptor),
        {Element *} attr(Class obj) => attribute.bind(obj).get()
    ) 
    //given Element satisfies Object
            => withAttributesInternal( attribute, attribute(expected).get(), matcherFactory, descriptor, ContainsExactlyMatcher<Element>); 
    
    ObjectMatcherBuilder<Class> withConvertedAttributesInternal<Element, RawElement> (
        <Attribute<Class, RawElement /*{Element *}*/, Nothing> /*|<{Element *} (Class)>*/ > attribute,
        RawElement expected,
        Matcher<Element>(Element) matcherFactory,
        Descriptor descriptor,
        Matcher<{Element *}> iterableCompare({Matcher<Element> *} ms, Descriptor descriptor ),
        
        {Element *} convert (RawElement rawElement)
    ) 
    //given Element satisfies Object 
    {
        {Matcher<Element> *} ms = {for(e in convert(expected)) matcherFactory(e) };
        Matcher<{Element? *}> matcher = iterableCompare(ms, descriptor);
        
        value attrMatcher = IndirectAttributeMatcher<Class, {Element? *}, RawElement>(matcher, attribute, convert);
        children.add(attrMatcher);
        
        return this;
    }
    
    shared ObjectMatcherBuilder<Class> withConvertedAttributes<Element, RawElement> (
        <Attribute<Class, RawElement /*{Element *}*/, Nothing> /*|<{Element *} (Class)>*/ > attribute,
        RawElement expected,
        Matcher<Element>(Element) matcherFactory,
        Descriptor descriptor,
        Matcher<{Element *}> iterableCompare({Matcher<Element> *} ms, Descriptor descriptor ),
        
        {Element *} convert (RawElement rawElement)
    ) 
            => withConvertedAttributesInternal( attribute, expected, matcherFactory, descriptor, ContainsExactlyMatcher<Element>, convert); 
    
    shared ObjectMatcherBuilder<Class> withConvertedAttributesInAnyOrder<Element, RawElement> (
        Attribute<Class, RawElement, Nothing> attribute,
        RawElement expected,
        Matcher<Element>(Element) matcherFactory,
        {Element *} convert (RawElement rawElement),
        Descriptor descriptor = DefaultDescriptor()
    ) 
            => withConvertedAttributesInternal( attribute, expected, matcherFactory, descriptor, ContainsInAnyOrderMatcher<Element>, convert); 
    
}
