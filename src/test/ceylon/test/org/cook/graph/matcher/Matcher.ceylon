import ceylon.collection {
	ArrayList
}
import ceylon.language.meta {
	type
}




shared interface SelfDescribing {
	shared formal void describeTo(TextBuilder textBuilder);
}


shared interface MatcherFactory<out T> {
	shared formal Matcher<T> get();
}

"Matches an actual value against some criterion (usually an 'expected' value passed to constructor).
 "
by ("Jean-Pierre Ragey")
shared interface Matcher<out T> satisfies SelfDescribing {
	
	"""Simply match expected/actual"""
	shared formal Boolean match(Anything actual);
	
	//shared formal void describeExpected(TextBuilder textBuilder);
	
	// TODO: maybe should not be in matcher
	shared formal void describeActual(Anything actual, TextBuilder textBuilder);
	
	shared default String describeActualAsString(Anything actual, TextBuilder textBuilder = DefaultTextBuilder(DefaultDescriptor())) {
		describeActual(actual, textBuilder);
		String result = textBuilder.string;
		return result;
	}
	
	shared default String describeMatcherAsString(TextBuilder textBuilder = DefaultTextBuilder(DefaultDescriptor())) {
		describeTo(textBuilder);
		String result = textBuilder.string;
		return result;
	}
	
	shared formal Description explainFully(Anything actual, Descriptor descriptor);
	
	shared default Matcher<T & Q> or<Q>(Matcher<Q> matcher) => BinaryOrMatcher(this,matcher);
	shared default Matcher<T & Q> and<Q>(Matcher<Q> matcher) => BinaryAndMatcher(this,matcher);
	shared default Matcher<T & Q> andNot<Q>(Matcher<Q> matcher) => BinaryAndNotMatcher(this,matcher);
	shared default Matcher<T> not() => UnaryNotMatcher(this);
	
	//shared default Matcher<S> as<S>(T(S) converter) => UnaryNotMatcher(this);
	
}

""
shared class AsMatcher<T, S>(Matcher<T> matcher, T(S) converter) satisfies Matcher<S> {
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) // TODO 
			=> matcher.describeActual(actual, textBuilder);
	
	shared actual void describeTo(TextBuilder textBuilder) // TODO 
			=> matcher.describeTo(textBuilder);
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) // TODO 
			=> matcher.explainFully(actual, descriptor);
	
	shared actual Boolean match(Anything actual) {
		if(is S actual) {
			T t = converter(actual);
			return matcher.match(t);
		} else {
			return false;
		}
	}
}


suppressWarnings("expressionTypeNothing")
shared class BinaryOrMatcher<P, Q>(
	shared Matcher<P> m0,
	shared Matcher<Q> m1
) satisfies Matcher<P & Q> 
		{
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) {}
	
	shared actual void describeTo(TextBuilder textBuilder) {}
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) => nothing;
	
	shared actual Boolean match(Anything actual) => nothing;
	
}
suppressWarnings("expressionTypeNothing")
shared class BinaryAndMatcher<P, Q>(
	shared Matcher<P> m0,
	shared Matcher<Q> m1
) satisfies Matcher<P & Q> 
		{
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
		textBuilder.appendValue(actual else "<null>");
	}
	
	shared actual void describeTo(TextBuilder textBuilder) {
		textBuilder.appendDescriptionOf(m0).appendText(" and ").appendDescriptionOf(m1);
	}
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) => nothing;
	
	shared actual Boolean match(Anything actual) => m0.match(actual) && m1.match(actual);
	
}

suppressWarnings("expressionTypeNothing")
shared class BinaryAndNotMatcher<P, Q>(
	shared Matcher<P> m0,
	shared Matcher<Q> m1
) satisfies Matcher<P & Q> 
		{
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) {}
	
	shared actual void describeTo(TextBuilder textBuilder) {}
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) => nothing;
	
	shared actual Boolean match(Anything actual) => nothing;
	
}
suppressWarnings("expressionTypeNothing")
shared class UnaryNotMatcher<P>(
	shared Matcher<P> m0
) satisfies Matcher<P> 
		{
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) {}
	
	shared actual void describeTo(TextBuilder textBuilder) {}
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) => nothing;
	
	shared actual Boolean match(Anything actual) => nothing;
	
}




String classNameForNullable<T>(T obj) {
	if(exists obj) {
		try {
			//return className(obj); 
			return type(obj).string; 
		} catch (Exception e) { // NPE: ceylon occasionally bugs
			return "(Couldn't be determined, Ceylon issue)";
		}
	}
	return "<null>";
}

shared interface TypeSafeCombinableMatcher<T> 
		satisfies Matcher<T> 
		{
	"""Simply match expected/actual"""
	shared actual Boolean match(Anything actual) {
		if(is T actual) {
			return typeSafeMatch(actual);
		} else {
			return false;
		}
	}
	shared formal Boolean typeSafeMatch(T actual);
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) {
		if(is T actual) {
			return typeSafeExplainFully(actual, descriptor);
		} else {
			return Description{
				explain = "Type mismatch: expected `` `T` ``, actual is `` classNameForNullable(actual) ``";
				children = [
				Description("actual:", [descriptor.describeFully(actual, descriptor)])
				];
				highlight = errorHighlight;
			};
		}
	}
	shared formal Description typeSafeExplainFully(T actual, Descriptor descriptor);
	//shared formal Description explainExpectedFully(T expected, Descriptor descriptor);
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
		if(is T actual) {
			//return typeSafeExplainFully(actual, descriptor);
			typeSafeDescribeActual(actual, textBuilder);
		} else {
			if(exists actual) {
				//textBuilder.appendText("``className(actual)``:``actual``");
				textBuilder.appendValue(actual);
			} else {
				textBuilder.appendText("<null>");
			}
		}
	}
	shared formal void typeSafeDescribeActual(T actual, TextBuilder textBuilder);
	
}

"Matches a {T *}"
shared interface IterableMatcher<T> 
		satisfies Matcher<{T*}> 
		{
	"""Simply match expected/actual"""
	shared actual Boolean match(Anything actual) {
		//        if(is {T*} actual) {
		if(is {Anything *} actual) {
			value list = ArrayList<T>(actual.size);
			for(a in actual) {
				if(is T a) {
					list.add(a);
				} else {    // wrong type
					return false;
				}
			}
			
			return matchIterable(list);
		} else {
			return false;
		}
	}
	shared formal Boolean matchIterable({T*} actuals);
	
	shared actual Description explainFully(Anything actual, Descriptor descriptor) {
		if(is {Anything *} actual) {
			value list = ArrayList<T>(actual.size);
			for(a in actual) {
				if(is T a) {
					list.add(a);
				} else {    // wrong type
					return Description{
						explain = "Type mismatch: expected Iterable<`` `T` ``>, an actual element is `` classNameForNullable(a) ``";
						children = [
						Description("actual element:", [descriptor.describeFully(a, descriptor)])
						];
						highlight = errorHighlight;
					};
				}
			}
			return explainIterableFully(list, descriptor);
		} else {
			return Description{
				explain = "Type mismatch: expected Iterable<`` `T` ``>, actual is `` classNameForNullable(actual) ``";
				children = [
				Description("actual:", [descriptor.describeFully(actual, descriptor)])
				];
				highlight = errorHighlight;
			};
		}
	}
	shared formal Description explainIterableFully({T *} actuals, Descriptor descriptor);
	//shared formal Description explainExpectedFully(T expected, Descriptor descriptor);
	
	shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
		if(is {T*} actual) {
			describeActualIterable(actual, textBuilder);
		} else {
			if(exists actual) {
				textBuilder.appendValue(actual);
			} else {
				textBuilder.appendText("<null>");
			}
		}
	}
	shared formal void describeActualIterable({T *} actuals, TextBuilder textBuilder);
	
}







