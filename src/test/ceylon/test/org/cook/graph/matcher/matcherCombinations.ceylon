import ceylon.collection { ArrayList }

/**
 // -- matcher combinations
Matcher<T>                   allOf<T> (Matcher<T>* matchers) => AllMatcher(matchers);
Matcher<T>                   anyOf<T> (Matcher<T>* matchers) => AnyMatcher(matchers);
CombinableMatcher<T>         not<T>   ( "the matcher whose sense should be inverted" Matcher<T> matcher) => NotMatcher(matcher);
CombinableBothMatcher<T>     both<T>  (Matcher<T> matcher) => CombinableBothMatcher(matcher);
CombinableEitherMatcher<T>   either<T>(Matcher<T> matcher) => CombinableEitherMatcher(matcher);

 */


"Compound matcher, matches when all child matchers match."
by ("Jean-Pierre Ragey")
shared class AllMatcher<T> (
    "Children matchers"
    Matcher<T>+ children
) satisfies Matcher<T> 
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
                then "All matched"
                else "Mismatched: only ``matchCount`` matched for ``matcherNb`` matchers";
            highlight = allMatched then noHighlight else errorHighlight;
            children = sb.sequence();
        };
    }
    
    
    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        textBuilder.appendValue(actual else "<null>");
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
            .appendText("all of ")
            .appendList("{", ", ", "}", children);
    }
    
    
}

"Creates a matcher that matches if the examined object matches <b>ALL</b> of the specified matchers.
 For example:
 assertThat(\"myValue\", allOf(startsWith(\"my\"), containsString(\"Val\")))
 "
shared Matcher<T> allOf<T>(Matcher<T>+ matchers) => AllMatcher(*matchers);



"Compound matcher, matches when any child matcher match."
by ("Jean-Pierre Ragey")
shared class AnyMatcher<T> (
    "Children matchers"
    Matcher<T>+ children
) satisfies Matcher<T> 
        {
    shared actual Boolean match(Anything actual) {
        for(m in children) {
            if(m.match(actual)) {
                return true;
            }
        }
        return false;
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
        Boolean anyMatched = (matchCount != 0);
        return Description{
            explain = anyMatched
                then "Matched: ``matchCount`` matches for ``matcherNb`` matchers"
                else "No match";
            highlight = anyMatched then noHighlight else errorHighlight;
            children = sb.sequence();
        };
    }
    
    
    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        textBuilder.appendValue(actual else "<null>");
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("any of ")
                .appendList("{", ", ", "}", children);
    }
    
    
}

"Creates a matcher that matches if the examined object matches <b>ALL</b> of the specified matchers.
 For example:
 assertThat(\"myValue\", allOf(startsWith(\"my\"), containsString(\"Val\")))
 "
shared Matcher<T> anyOf<T>(Matcher<T>+ matchers) => AnyMatcher(*matchers);


"Matches when child fails, and vice-versa."
by ("Jean-Pierre Ragey")
shared class NotMatcher<T> (
    "Child matcher"
    Matcher<T> matcher
) satisfies Matcher<T> 
        {

    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        if(exists actual) {
            textBuilder.appendValue(actual);
        } else {
            textBuilder.appendText("<null>");
        }
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("not (")
                .appendDescriptionOf(matcher)
                .appendText(")")
        ;
    }
    
    shared actual Description explainFully(Anything actual, Descriptor descriptor) {
        Description d = matcher.explainFully(actual, descriptor);
        if(match(actual)) {
            return Description("Not operator matched", [d]);
        } else {
            return Description("Not operator did not match", [d], errorHighlight);
        }
    }
    
    shared actual Boolean match(Anything actual) => !matcher.match(actual);
    
}

" Creates a matcher that wraps an existing matcher, but inverts the logic by which
 it will match.
 
 For example:
 assertThat(cheese, is(not(eq(smelly))));
 "
shared Matcher<T> not<T>(
    "the matcher whose sense should be inverted" 
    Matcher<T> matcher
) => NotMatcher(matcher);


////////////////////////////////////////////


shared class CombinableBothMatcher<T>(Matcher<T> firstMatcher) {
    shared AllMatcher<T> and(Matcher<T> matcher) {
        return AllMatcher<T>(firstMatcher, matcher);
    }
}

shared CombinableBothMatcher<T> both<T>(Matcher<T> matcher) 
        => CombinableBothMatcher(matcher);



"Compound matcher, matches when all either matcher match."
by ("Jean-Pierre Ragey")
shared class EitherMatcher<T> (
    Matcher<T> matcher0,
    Matcher<T> matcher1
) satisfies Matcher<T> 
{
    
    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        textBuilder.appendValue(actual else "<null>");
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder
                .appendText("either (")
                .appendDescriptionOf(matcher0)
                .appendText(") or (")
                .appendDescriptionOf(matcher1)
                .appendText(")")
        ;
    }
    
    shared actual Description explainFully(Anything actual, Descriptor descriptor) {
        return Description {
            explain = "Either";
            children = [
                matcher0.explainFully(actual, descriptor),
                matcher1.explainFully(actual, descriptor)
            ];
            highlight = match(actual) then noHighlight else errorHighlight;
        };
    }
    
    shared actual Boolean match(Anything actual) => matcher0.match(actual) != matcher1.match(actual);
    
    //"AllMatcher short description: \"All\""
    //shared actual Description description(/*Matcher<T> (T? ) resolver*/) => StringDescription("Either", normalStyle); 
    //shared actual TextNode shortDescription(Descriptor descriptor, DescriptorEnv descriptorEnv) => tnode("Either");
    //
    //shared actual void describeTo(TextBuilder textBuilder) => textBuilder
    //        .appendText("(either ")
    //        .appendDescriptionOf(matcher0)
    //        .appendText(" or ")
    //        .appendDescriptionOf(matcher1)
    //        .appendText(")");
    //
    //
    //"Succeeds if all child matchers match."
    //shared actual MatcherResult match(Object? actual/*, Matcher<T> (T? ) matcherResolver*/, Boolean mustExplain) {
    //    MatcherResult mr0 = matcher0.match(actual/*, matcherResolver*/, mustExplain);
    //    MatcherResult mr1 = matcher1.match(actual/*, matcherResolver*/, mustExplain);
    //    
    //    Boolean success = (mr0.succeeded != mr1.succeeded);
    //    String successStr(Boolean b) => b then "success" else "failed";
    //    
    //    StringDescription rootDescription = success 
    //    then StringDescription("Either() operator succeeded (``successStr(mr0.succeeded)`` / ``successStr(mr1.succeeded)``)")
    //    else StringDescription("")
    //    ;
    //    
    //    value descr = TreeDescription(rootDescription, {
    //        mr0.matchDescription, 
    //        mr1.matchDescription
    //    });
    //    return MatcherResult(success, descr, (Descriptor descriptor, DescriptorEnv de)=>TextNode("TODO"));
    //}
    
}

shared class CombinableEitherMatcher<T>(Matcher<T> firstMatcher) {
    shared EitherMatcher<T> or(Matcher<T> matcher) {
        return EitherMatcher<T>(firstMatcher, matcher);
    }
}




shared CombinableEitherMatcher<T> either<T>(Matcher<T> matcher) 
        => CombinableEitherMatcher(matcher);

