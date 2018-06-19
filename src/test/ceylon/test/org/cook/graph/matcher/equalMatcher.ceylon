import ceylon.language.meta { type }



shared Boolean equalsOrNull<T>(T actual, T expected) {
    if(exists expected, exists actual) {
        return expected == actual;
    } else {
        return (actual is Null) && (expected is Null);
    }
}

shared class EqualsOpMatcher<T>(
    "The expected value"
    T expected,
    Boolean doMatch(T actual, T expected) => equalsOrNull(actual, expected),
    String shortOpDescription = "=="
    
) satisfies Matcher<T> 
        //given T satisfies Object
{
    shared actual Boolean match(Anything actual) {
        //if(exists expected) {
            if(is T actual) {
                return doMatch(actual, expected);
            } else {
                return false;   // expected != null, actual == null
            }
        //} else {    // expected is null
        //    return actual is Null;
        //}
    }
    shared actual Description explainFully(Anything actual, Descriptor descriptor) {
        String actualName {
            if(exists actual) {return classNameForNullable(actual);} else {return "<null>";}
        }
        
        if(exists expected) {
            
            if(is T actual) {
                Boolean match = doMatch(actual, expected);
//                String explainTypes;
                Boolean sameType;
                if(exists actual) {
                    sameType = type<Object>(actual) == `T`;
                } else {    // actual is null
                    sameType = `Null` == `T`;   // TODO: ???
                }
                String explainTypes = sameType 
                    then `T`.string
                    else "expected type is `` `T` ``, actual is `` actualName ``";
                
                return Description("``match then "Match" else "Mismatch" `` for ``shortOpDescription`` : ``explainTypes``", [
                    Description("actual:   ", [descriptor.describeFully(actual, descriptor)], match then noHighlight else errorHighlight),
                    Description("expected: ", [explainExpectedFully(expected, descriptor)])
                ]);
            } else {    // expected != null, actual is not T
                return Description("Mismatch for ``shortOpDescription`` : expected type is `` `T` ``, actual is `` actualName ``", [
                    Description("actual:   ", [descriptor.describeFully(actual, descriptor)], errorHighlight),
                    Description("expected: ", [explainExpectedFully(expected, descriptor)])
                ]);
            }
        } else {    // expected is null
            if(exists actual) {
                return Description("Mismatch for ``shortOpDescription`` : expected null, actual is `` actualName ``", [
                    Description("actual:   ", [descriptor.describeFully(actual, descriptor)], errorHighlight)
                ]);
                
            } else { // expected == actual == null
                return Description("Match for ``shortOpDescription``: expected == null, actual == null");
            }
        }
        
    }
    
    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        if(exists actual) {
            textBuilder.appendValue(actual);
        } else {
            textBuilder.appendText("<null>");
        }
    }
    
    
    
    ////shared actual Boolean typeSafeMatch(T actual) {
    ////    if(is T expected) {
    ////        return doMatch(actual, expected);
    ////    } else {
    ////        return false;
    ////    }
    ////}
    //
    //shared actual Description typeSafeExplainFully(T actual, Descriptor descriptor) {
    //    variable String actualName = className(actual);
    //    
    //    if(is T expected) {
    //        Boolean match = doMatch(actual, expected);
    //        
    //        return Description("``match then "Match" else "Mismatch" `` for ``shortOpDescription`` : expected type is `` `T` ``, actual is `` actualName ``", {
    //            Description("actual:   ", {descriptor.describeFully(actual)}, match then noHighlight else errorHighlight),
    //            Description("expected: ", {explainExpectedFully(expected, descriptor)})
    //        });
    //    } else {
    //        return Description("Mismatch for ``shortOpDescription`` : expected <null>, actual is `` actualName ``", {
    //            Description("actual:   ", {descriptor.describeFully(actual)}, errorHighlight)
    //        });
    //    }
    //}
    Description explainExpectedFully(T expected, Descriptor descriptor) {
        return descriptor.describeFully(expected, descriptor);
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder.appendText(shortOpDescription);
        //if(is T expected) {
            textBuilder.appendValue<T>(expected);
        //} else {
        //    textBuilder.appendText("<null>");
        //}
    }
}


shared EqualsOpMatcher<T> equalTo<T>(T expected) {
    return EqualsOpMatcher<T>(expected, equalsOrNull<T>, "==");
}
shared EqualsOpMatcher<T> eq<T>(T expected) => equalTo(expected); 

shared EqualsOpMatcher<T> sameInstance<T>(T expected) given T satisfies Identifiable {
    return EqualsOpMatcher<T>(expected, (T actual, T expected) => actual === expected, "===");
} 




