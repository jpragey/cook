
"Thrown when some matcher didn't match an actual value."
shared class MatchException(String message, Description? description = null) 
        extends Exception(message) 
{
}

shared class ConfigurationException(String message) 
        extends Exception(message) 
{
}


"Handler for a match failure.
 Typically used by assertions (eg [[assertThat]]) to print a mismatch message in some way (text in console, HTML file, etc). 
 "
see (`function assertThat`)
by ("Jean-Pierre Ragey")
shared interface ResultHandler {
    shared formal void failed(
        Object? actual,
        Matcher<Anything> matcher
    );
}

"[[ResultHandler]] that print a detailed description and a stacktrace on stderr, and throws a [[MatchException]]."
shared class ThrowingResultHandler(
    Descriptor descriptor
)
    satisfies ResultHandler
{
    
    shared actual void failed(Object? actual, Matcher<Anything> matcher) {
        Description description = matcher.explainFully(actual, descriptor);
        
        // -- Dump error on stderr
        description.dumpDescription((String line, Integer indentCount) => process.writeErrorLine("`` "  ".repeat(indentCount) ````line``"));
        
        // -- Throw a MatchException
        String shortDescription = DefaultTextBuilder(descriptor)
                    .appendNewLine()
                    .appendText("actual:   ")
                    .appendDescriptionOf(descriptor.selfDescribing(actual))
                    .appendNewLine()
                    .appendText("expected: ")
                    .appendDescriptionOf(matcher)
                    .string;

        value e = MatchException(shortDescription, description);
        
        e.printStackTrace();
        throw e;
    }
    
}


"General-purpose assertion.
 It matches an 'actual' object against a predefined Matcher; if it failed, it let a [[ResultHandler]] react. 
 "
shared void assertThat<T>(
    Object? actual, 
    <Matcher<T> |  MatcherFactory<T>> matcher, 
    ResultHandler resultHandler = ThrowingResultHandler(DefaultDescriptor())
) 
{
    Matcher<T> effectiveMatcher;
    if(is Matcher<T> matcher) {
        effectiveMatcher = matcher;
    } else {
        effectiveMatcher = matcher.get();
    //} else {
    //    throw AssertionError("Matcher ``matcher`` must be a Matcher<> or a MatcherFactory<>");
    }
    
    if(!effectiveMatcher.match(actual)) {
        resultHandler.failed(actual, effectiveMatcher);
    }
}

//shared void assertThat1<T>(
//	Object? actual, 
//	<Matcher<T> | MatcherFactory<T> > matcher, 
//	ResultHandler resultHandler = ThrowingResultHandler(DefaultDescriptor())
//) {}
//
//shared void assertThat2<T>(
//	Object? actual, 
//	<Matcher<T> |  MatcherFactory<T> > matcher, 
//	ResultHandler resultHandler = ThrowingResultHandler(DefaultDescriptor())
//) 
//{
//	Matcher<T> effectiveMatcher;
//	if(is Matcher<T> matcher) {
//		effectiveMatcher = matcher;
//	} else {
//		effectiveMatcher = matcher.get();
//		//} else {
//		//    throw AssertionError("Matcher ``matcher`` must be a Matcher<> or a MatcherFactory<>");
//	}
//	
//	if(!effectiveMatcher.match(actual)) {
//		resultHandler.failed(actual, effectiveMatcher);
//	}
//}
