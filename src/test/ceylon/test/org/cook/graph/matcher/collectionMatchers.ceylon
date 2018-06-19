import ceylon.collection {
	ArrayList
}


"Helper: check that actual is an Iterable<Elem?>, then call [[callback]]."
Description callForIterable<Elem>(Anything actual, Descriptor descriptor, Description(Iterable<Elem>) callback) {
    Description result;
    
    if(is Iterable<Object?> actual) {
        if(is Iterable<Elem> actual) {
            result = callback(actual);
        } else {
            result = Description("An Iterable<`` `Elem` ``> was expected, found ``classNameForNullable(actual)``:", [
                for(obj in actual) 
                    descriptor.describeFully(obj, descriptor)
            ], errorHighlight);
        }
    } else if(exists actual){
        result = Description("An Iterable<`` `Elem` ``> was expected, found ``classNameForNullable(actual)``", [
            Description("value:", [descriptor.describeFully(actual, descriptor)])
            ], errorHighlight);
    } else {
        result = Description("An Iterable<`` `Elem` ``> was expected, found <null>", [], errorHighlight);
    }
    return result;    
}

" Creates a matcher for {@link Iterable}s that only matches when a single pass over the
 examined {@link Iterable} yields items that are all matched by the specified
 [[itemMatcher]].
 For example:
 assertThat({\"bar\", \"baz\"}, EveryItemMatcher(startsWith(\"ba\")));
 "
shared class EveryItemMatcher<U> (
    "the matcher to apply to every item provided by the examined [[Iterable]]"
    Matcher<U> itemMatcher
) 
        satisfies TypeSafeCombinableMatcher<{U?*}>
        //given U satisfies Object 
{
    shared actual Boolean typeSafeMatch({U?*} actual) {
        for(item in actual) {
            if(!itemMatcher.match(item)) {
                return false;
            }
        }
        return true;
    }
    shared actual Description typeSafeExplainFully({U?*} actual, Descriptor descriptor) {
        
        variable Integer matchCount = 0;
        value childrenSb = ArrayList<Description>();
        for(item in actual) {
             if(itemMatcher.match(item)) {
                 matchCount ++;
             }
             Description child = itemMatcher.explainFully(item, descriptor);
             childrenSb.add(child);
        }
        
        Boolean matched = matchCount == actual.size;
        [Description *] children = childrenSb.sequence();
        
        return Description(
            matched 
                then "All items matched" 
                else "Mismatch: not all items matched (matched: ``matchCount``/``actual.size``)", 
            [
                Description("Actual items:" ,children)
            ]
        );
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder.appendText("all match ").appendDescriptionOf(itemMatcher);
    }
    
    shared actual void typeSafeDescribeActual({U?*} actual, TextBuilder textBuilder) {
        textBuilder.appendValueList("{", ", ", "}", actual);
    }
    
}

" Creates a matcher for [[Iterable]]s that only matches when a single pass over the
 examined Iterable yields items that are all matched by the specified
 [[itemMatcher]].
 For example:
     assertThat({\"bar\", \"baz\"}, everyItem(startsWith(\"ba\")));
 "
see(`class EveryItemMatcher`)

shared Matcher<{U?*}> everyItem<U>(
    Matcher<U> itemMatcher
) given U satisfies Object 
        => EveryItemMatcher(itemMatcher);










"Matcher that matches an Iterable<Anything>.
 
 
 "
/*
 Examples: 
 TypeSafeCollectionMatcher
 */
shared interface TypeSafeCollectionMatcher<out Element>/*<T = Anything>*/ 
        satisfies Matcher<Element> 
{
    """Delegate to typeSafeMatch() if actual is an {Anything*}; otherwise return false."""
    shared actual Boolean match(Anything actual) {
        if(is {Anything*} actual) {
            return typeSafeMatch(actual);
        } else {
            return false;
        }
    }
    shared formal Boolean typeSafeMatch({Anything*} actual);
    
    ""
    shared actual Description explainFully(Anything actual, Descriptor descriptor) {
        if(is {Anything*} actual) {
            value d = typeSafeExplainFully(actual, descriptor);
            return d;
        } else {
            return Description{
                explain = "Type mismatch: expected an iterator, actual is `` classNameForNullable(actual) ``";
                children = [
                    Description("actual:", [descriptor.describeFully(actual, descriptor)])
                ];
                highlight = errorHighlight;
            };
        }
    }
    shared formal Description typeSafeExplainFully({Anything*} actual, Descriptor descriptor);
    
    shared actual void describeActual(Anything actual, TextBuilder textBuilder) {
        if(is {Anything *} actual) {
            typeSafeDescribeActual(actual, textBuilder);
        } else {
            textBuilder.appendOptionalValue(actual);
        }
    }
    shared formal void typeSafeDescribeActual({Anything *} element, TextBuilder textBuilder);
    
}



"
 Creates a matcher for [[Iterable]]s that only matches when a single pass over the
 examined [[Iterable]] yields at least one item that is equal to the specified
 *item*.  Whilst matching, the traversal of the examined [[Iterable]]
 will stop as soon as a matching item is found.
 
 For example:
     assertThat({\"foo\", \"bar\"}, hasItem(eq(\"bar\")))
 "
shared class HasItemMatcher<out Element>(
    Matcher<Element> itemMatcher
)  
        satisfies TypeSafeCollectionMatcher<Element>
{
    shared actual Boolean typeSafeMatch({Anything*} actual) {
        for(t in actual) {
            if(itemMatcher.match(t)) {
                return true;
            }
        }
        return false;
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder.appendText("has item ").appendDescriptionOf(itemMatcher);
    }
    
    shared actual void typeSafeDescribeActual({Anything *} actual, TextBuilder textBuilder) {
        textBuilder.appendValueList("[", ", ", "]", *actual);
    }
    
    shared actual Description typeSafeExplainFully({Anything*} actual, Descriptor descriptor) {
        Boolean matched = match(actual);

        value d = Description { 
            explain = matched then "One or more item(s) matched" else "No item matched"; 
            children = {for(e in actual) itemMatcher.explainFully(e, descriptor)}.sequence(); 
            highlight = matched then noHighlight else errorHighlight; 
        };
        return d;
    }
}

shared HasItemMatcher<Element> hasItem<out Element> (
    Matcher<Element> itemMatcher
) 
        => HasItemMatcher<Element>(itemMatcher); 




" Creates a matcher for {@link Iterable}s that matches when consecutive passes over the
 examined {@link Iterable} yield at least one item that is matched by the corresponding
 matcher from the specified <code>itemMatchers</code>.  Whilst matching, each traversal of
 the examined {@link Iterable} will stop as soon as a matching item is found.
 
 For example:
 assertThat({\"foo\", \"bar\", \"baz\"), hasItems(endsWith(\"z\"), endsWith(\"o\")))
 "
shared Matcher<Anything> hasItems (
    "the matchers to apply to items provided by the examined [[Iterable]]"
    Matcher<Anything>+ itemMatchers
) 
        => allOf(for(itemMatcher in itemMatchers) hasItem(itemMatcher));



void iteratePairs<U, V>({U*} heads, {V*} tails,
    Boolean(U, V) onPair,
    Boolean(U) extraHead,
    Boolean(V) extraTail
) {
    Iterator<U> headIt = heads.iterator();
    Iterator<V> tailIt = tails.iterator();
    while(true) {
        value h = headIt.next();
        value t = tailIt.next();
        
        if(! is Finished h) {
            if(! is Finished t) {
                if(!onPair(h, t)) {
                    break;
                }
            } else {
                if(! extraHead(h)) {
                    break;
                }
            }
        } else {
            if(! is Finished t) {
                if(! extraTail(t)) {
                    break;
                }
            } else {
                break;
            }
        }
    }
}

// Currently tests are done through contains() tests
"Matcher for `Iterable` values."
by ("Jean-Pierre Ragey")
shared class ContainsExactlyMatcher<Elem>(
    "Expected elements"
    {Matcher<Elem> *} matchers,
    "Descriptor for elements descriptions " 
    Descriptor descriptor = DefaultDescriptor()
) 
        satisfies IterableMatcher<Elem>
        //given Elem satisfies Object
        //satisfies TypeSafeCollectionMatcher
{
            
    shared actual Boolean matchIterable({Elem *} actuals) {
        if(actuals.size == matchers.size ) {
            variable Boolean matched = true;
            iteratePairs<Anything, Matcher<Anything>> {
                heads =  actuals;
                tails = matchers;
                onPair = (Anything elem, Matcher<Anything> matcher) {
                    if(! matcher.match(elem)) {
                        matched = false; 
                        return false;
                    } 
                    return true;
                };
                extraHead = (Anything elem)        {matched = false; return false;};  // never called 
                extraTail = (Matcher<Anything> m)  {matched = false; return false;};   // never called
            };
            return matched;
        } else {
            return false;
        }
    }

    
    shared actual Description explainIterableFully({Elem *} actuals, Descriptor descriptor) {
    
    //shared actual Description typeSafeExplainFully({Anything *}/*Elem*/ actual, Descriptor descriptor) {
        value commonsSb = ArrayList<Description>();
        value extraMatchersSb = ArrayList<Description>();
        value extraElmentsSb = ArrayList<Description>();
        variable Boolean matched = true;
        
        iteratePairs <Anything, Matcher<Anything>>{
            heads = actuals;
            tails = matchers;
            onPair = (Anything elem, Matcher<Anything> matcher) {
                if(! matcher.match(elem)) {
                    matched = false; 
                } 
                Description description = matcher.explainFully(elem, descriptor);
                commonsSb.add(description);
                return true;
            };
            extraHead = (Anything elem) {
                matched = false;
                extraElmentsSb.add(descriptor.describeFully(elem, descriptor));
                return true;
            }; 
            extraTail = (Matcher<Anything> matcher) {
                matched = false;
                String descr = matcher.describeMatcherAsString(DefaultTextBuilder(descriptor));
                extraMatchersSb.add(Description(descr)); // TODO: better than this 'short' decsription
                return true;
            }; 
        };
        
        value resultSb = ArrayList<Description>();
        resultSb.add(Description("Matching:",
            commonsSb.sequence()
        ));
        if(!extraMatchersSb.empty) {
            resultSb.add(Description("Matchers without corresponding element:",
                extraMatchersSb.sequence()
            ));
        }
        if(!extraElmentsSb.empty) {
            resultSb.add(Description("Elements without corresponding matcher:",
                extraElmentsSb.sequence()
            ));
        }
        
        Description result = Description(
            matched then "All elements matched" else "Not all elements matched", 
            resultSb.sequence(), 
            matched then noHighlight else errorHighlight
        ); 
        return result;
    }

    shared actual void describeActualIterable({Elem *} actuals, TextBuilder textBuilder) {
    //shared actual void typeSafeDescribeActual({Anything *}/*Elem*/ actual, TextBuilder textBuilder) {
        textBuilder.appendValueList("{", ", ", "}", actuals);
    }
    
    shared actual void describeTo(TextBuilder textBuilder) 
            => textBuilder.appendText("matches exactly ").appendList("[", ", ", "]", matchers);
    
}


//" Iterable exact match.
// 
// Creates a matcher for [[Iterable]]s that matches when a single pass over the
// examined {@link Iterable} yields a series of items, each satisfying the corresponding
// matcher in the specified matchers.  For a positive match, the examined iterable
// must be of the same length as the number of specified matchers.
// 
// For example:
// assertThat({\"foo\", \"bar\"}, contains({eq(\"foo\"), eq(\"bar\")}));
// "
shared ContainsExactlyMatcher<Elem> contains<Elem>(
    "the matchers that must be satisfied by the items provided by an examined [[Iterable]]"
    {Matcher<Elem> *} expected/*, Descriptor descriptor = DefaultDescriptor()*/
) 
        given Elem satisfies Object 
        => ContainsExactlyMatcher<Elem>(expected/*, descriptor*/);


"Matches a {T? *}, no matter the order."
shared class ContainsInAnyOrderMatcher<Elem>(
    "Expected elements"
    {Matcher<Elem>| MatcherFactory<Elem> *} matchersOrMatcherFactories,
    "Descriptor for elements descriptions " 
    Descriptor descriptor = DefaultDescriptor()
) satisfies IterableMatcher<Elem> 
        //given Elem satisfies Object
{
    Matcher<Elem> toMatcher(Matcher<Elem>| MatcherFactory<Elem> m) {
        if(is MatcherFactory<Elem> m) {
            return m.get();
        }
        //else if(is Matcher<Elem> m) {
        else {
            return m;
        }
        //throw AssertionError("ContainsInAnyOrderMatcher.matchers: expected MatcherFactory<Elem> or Matcher<Elem>, found `` m `` ");
    }
    {Matcher<Elem> *} matchers = [
        for(m in matchersOrMatcherFactories) 
            toMatcher(m)
    ];
    
    shared actual Boolean matchIterable({Elem *} actual) {
        if(matchersOrMatcherFactories.size != actual.size) {
            return false;
        }
        
        for(elem in actual) {
            if(! matchers.find((Matcher<Elem?> matcher) => matcher.match(elem)) exists) {
                return false;
            }
        }
        return true;
    }

    shared actual void describeActualIterable({Elem *} actual, TextBuilder textBuilder) {
        textBuilder.appendValueList("{", ", ", "}", *actual);
    }
        
    [Description*] matchersDescription() => [for(matcher in matchers) Description(matcher.describeMatcherAsString(DefaultTextBuilder(descriptor)))];
    [Description*] actualsDescription({Elem *} actuals) => [for(act in actuals) descriptor.describeFully(act, descriptor)];
     
    shared actual Description explainIterableFully({Elem *} actuals, Descriptor descriptor) {
        // -- Check matchers / actual sizes
        if(matchersOrMatcherFactories.size != actuals.size) {
            return Description("Matchers and actual sizes differ (``matchersOrMatcherFactories.size`` matchers, ``actuals.size`` actual items)", [
                Description("Matchers:", 
                    matchersDescription()
                ),
                Description("Actual items:", 
                    actualsDescription(actuals)
                )
            ],errorHighlight);
        }
        
        for(elem in actuals) {
            if(! matchers.find((Matcher<Elem?> matcher) => matcher.match(elem)) exists) {
                return Description("Actual item does not match any matcher:", [
                    Description("Matchers:", matchersDescription()),
                    Description("Mismatching actual item:", 
                        [descriptor.describeFully(elem, descriptor)]
                    )
                ],errorHighlight);
            }
        }
        Description result = Description("All items matched a matcher (in any order)", [
            Description("Matchers:", 
                matchersDescription()
            ),
            Description("Actual items:", 
                actualsDescription(actuals)
            )
        ]);

        return result;
    }

    shared actual void describeTo(TextBuilder textBuilder) 
            => textBuilder.appendText("matches in any order").appendList("[", ", ", "]", matchers);
}

shared Matcher<{T *}> containsInAnyOrder<T>(
    {Matcher<T> | MatcherFactory<T> *} matchers,
    Descriptor descriptor = DefaultDescriptor()
) 
        => ContainsInAnyOrderMatcher(matchers, descriptor);


" 
 "
shared class EmptyMatcher() 
        satisfies IterableMatcher<Anything>
{

    shared actual Boolean matchIterable({Anything *} actuals) => actuals.empty;

    shared actual Description explainIterableFully({Anything *} actuals, Descriptor descriptor) {
        value result = Description(
            actuals.empty then "Empty matcher matched" else "Empty matcher: iterable not empty", 
            [for(act in actuals) 
                descriptor.describeFully(act, descriptor)
            ],
            actuals.empty then noHighlight else errorHighlight
        );
        return result;
    }
    
    shared actual void describeActualIterable({Anything *} actuals, TextBuilder textBuilder) {
        textBuilder.appendValueList("{", ", ", "}", *actuals);
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder.appendText("empty iterable");
    }
    
    
}

shared EmptyMatcher empty() => EmptyMatcher(); 


"Creates a matcher for arrays that matches when the length of the iterable equals the specified size.
 
 For example:
 assertThat({\"foo\", \"bar\", \"baz\"}, iterableWithSize(3));
 "
shared class IterableWithSizeMatcher(
    "Creates a matcher for iterables that matches when the length of the array equals the specified size. "
    Integer size 
) 
        satisfies IterableMatcher<Anything> 
{
    shared actual Boolean matchIterable({Anything *} actuals) => actuals.size == size;
    
    shared actual Description explainIterableFully({Anything *} actuals, Descriptor descriptor) {
        Boolean matched = actuals.size == size;
        value result = Description(
            matched 
                then "Iterator of size ``size`` matched" 
                else "Iterator of size ``size`` mismatch: ``actuals.size`` items found", 
            [for(act in actuals) 
                descriptor.describeFully(act, descriptor)
            ],
            matched then noHighlight else errorHighlight
        );
        return result;
        
    }
    
    shared actual void describeActualIterable({Anything *} actuals, TextBuilder textBuilder) {
        textBuilder.appendValueList("{", ", ", "}", *actuals);
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder.appendText("an iterable of size ``size``");
    }
    
    
    
}


shared IterableWithSizeMatcher iterableWithSize(
    "Creates a matcher for arrays that matches when the length of the array equals the specified size. "
    Integer size 
) => IterableWithSizeMatcher(size);


"Creates a matcher for arrays that matches when the length of the array equals the specified size.
 
 For example:
 assertThat({\"foo\", \"bar\", \"baz\"}, iterableWithSize(3));
 "
shared class HasSizeMatcher(
    "Creates a matcher for arrays that matches when the length of the array equals the specified size. "
    Matcher<Integer> sizeMatcher 
) 
        satisfies IterableMatcher<Anything> 
{
    
    shared actual Boolean matchIterable({Anything *} actuals) => sizeMatcher.match(actuals.size);

    shared actual Description explainIterableFully({Anything *} actuals, Descriptor descriptor) {
        Boolean matched = sizeMatcher.match(actuals.size);
        //Description sizeMatcherDescr = Description(sizeMatcher.describeMatcherAsString(DefaultTextBuilder(descriptor)));
        value result = Description(
            matched 
                then "Iterator size matched" 
                else "Iterator size mismatch: ``actuals.size`` items found", 
            [
                Description("Size matcher:", [
                    Description(sizeMatcher.describeMatcherAsString(DefaultTextBuilder(descriptor)))    // TODO: full description
                ]),
                Description("Actual items:", [
                    for(act in actuals) 
                        descriptor.describeFully(act, descriptor)
                ])
                 
            ],
            matched then noHighlight else errorHighlight
        );
        return result;
    }
    
    shared actual void describeActualIterable({Anything *} actuals, TextBuilder textBuilder) {
        textBuilder.appendValueList("{", ", ", "}", *actuals);
    }
    
    shared actual void describeTo(TextBuilder textBuilder) {
        textBuilder.appendText("an iterable of size matching ").appendDescriptionOf(sizeMatcher);
    }
}


shared class IsOneOfMatcher<Value>(
    {Value*} values,
    Matcher<Value>(Value) valueMatcher = eq<Value>,
    //Boolean valueMatch(Value actual, Value expected) => expected == actual,    
    Descriptor descriptor = DefaultDescriptor()
)
        satisfies TypeSafeCombinableMatcher<Value>
        given Value satisfies Object
{

    shared actual void describeTo(TextBuilder textBuilder) 
            => textBuilder.appendValueList("one of (", ", ", ")", *values);
    
    shared actual Boolean typeSafeMatch(Value actual) {
        for(expected in values) {
            if(!valueMatcher(expected).match(actual)) {
                return true;
            }
        }
        return false;
    }
    shared actual Description typeSafeExplainFully(Value actual, Descriptor descriptor) {
        
        variable Boolean matched = false;
        ArrayList<Description> descriptionSb = ArrayList<Description>();  
        for(expected in values) {
            Matcher<Value> matcher = valueMatcher(expected); 
            if(matcher.match(actual)) {
                matched  = true;
            }
            Description matchDescr = matcher.explainFully(actual, descriptor);
            descriptionSb.add(matchDescr);
        }
        
        value result = Description(
            matched 
                then "IsOneOf matched" 
                else "IsOneOf mismatch", 
            [
                Description("Values matching:", descriptionSb.sequence())
            ],
            matched then noHighlight else errorHighlight
        );
        return result;
    }
    
    shared actual void typeSafeDescribeActual(Value actual, TextBuilder textBuilder) {
        textBuilder.appendValue(actual);
    }
    
    
    
}

shared IsOneOfMatcher<Value> isOneOf<Value>(
    Value* values
) given Value satisfies Object
        => IsOneOfMatcher<Value>(values);





void dumpMap<Key, Value>(Map<Key,Value> actual, TextBuilder textBuilder) 
        given Key satisfies Object
        given Value satisfies Object
{
    //        textBuilder.appendValue(actual);
    textBuilder.appendText("[");
    variable Boolean first = true; 
    for(key->val in actual) {
        if(!first) {
            textBuilder.appendText(", ");    
        }
        first = false;
        textBuilder.appendValue(key);    
        textBuilder.appendText("->");    
        textBuilder.appendValue(val);    
    }
    textBuilder.appendText("]");
}

"
 "
shared class HasKeyMatcher<Key=Object>(
    Matcher<Key> keyMatcher
    //"Descriptor for found key."
    //Descriptor descriptor = DefaultDescriptor()
) 
        satisfies TypeSafeCombinableMatcher<Map<Key, Object>>
        given Key satisfies Object 
{
    shared actual Boolean typeSafeMatch(Map<Key,Object> actual) {
        for(key in actual.keys) {
            if(keyMatcher.match(key)) {
                return true;
            }
        }    
        return false;    
    }
    shared actual Description typeSafeExplainFully(Map<Key,Object> actual, Descriptor descriptor) {
        variable Boolean matched = false;
        
        ArrayList<Description> descriptionSb = ArrayList<Description>();  
        for(key in actual.keys) {
            if(keyMatcher.match(key)) {
                matched = true;
            }
            
            Description keyMatchDescr = keyMatcher.explainFully(key, descriptor);
            descriptionSb.add(keyMatchDescr);
        }    
        
        value result = Description(
            matched 
                then "A key matched" 
                else "No key matched", 
            [
                Description("Keys matching:", descriptionSb.sequence())
            ],
            matched then noHighlight else errorHighlight
        );
        return result;
    }
    
    shared actual void describeTo(TextBuilder textBuilder) => textBuilder
            .appendText("has key ")
            .appendDescriptionOf(keyMatcher);

    shared actual void typeSafeDescribeActual(Map<Key,Object> actual, TextBuilder textBuilder)
        => dumpMap(actual, textBuilder); 
}

"Creates a matcher for {@link java.util.Map}s matching when the examined {@link java.util.Map} contains
 at least one key that satisfies the specified matcher.
 
 For example:
 assertThat(HashMap{\"f\"->\"foo\", \"b\"->\"bar\"}, hasKey(eq(\"b\")));
 "
shared HasKeyMatcher<Key> hasKey<Key>
        (
    "the matcher that must be satisfied by at least one key"
    Matcher<Key> keyMatcher
) 
        given Key satisfies Object 
        => HasKeyMatcher<Key>(keyMatcher) ;


shared class HasValueMatcher<Value=Object>(
    Matcher<Value> valueMatcher
    //,
    //"Descriptor for found value."
    //Descriptor descriptor = DefaultDescriptor()
) 
        satisfies TypeSafeCombinableMatcher<Map<Object, Value>>
        given Value satisfies Object 
{
    
    
    
    shared actual Boolean typeSafeMatch(Map<Object,Value> actual) {
        for(val in actual.items) {
            if(valueMatcher.match(val)) {
                return true;
            }
        }    
        return false;    
    }

    shared actual Description typeSafeExplainFully(Map<Object,Value> actual, Descriptor descriptor) {
        variable Boolean matched = false;
        
        value descriptionSb = ArrayList<Description>();  
        for(val in actual.items) {
            if(valueMatcher.match(val)) {
                matched = true;
            }
            
            Description valueMatchDescr = valueMatcher.explainFully(val, descriptor);
            descriptionSb.add(valueMatchDescr);
        }    
        
        value result = Description(
            matched 
                then "A value matched" 
                else "No value matched", 
            [
                Description("Values matching:", descriptionSb.sequence())
            ],
            matched then noHighlight else errorHighlight
        );
        return result;
        
    }

    shared actual void describeTo(TextBuilder textBuilder) 
            => textBuilder
                .appendText("has value ")
                .appendDescriptionOf(valueMatcher);
    
    shared actual void typeSafeDescribeActual(Map<Object,Value> actual, TextBuilder textBuilder)
            => dumpMap(actual, textBuilder); 
    
}

shared HasValueMatcher<Value> hasValue<Value>
        (
    "the matcher that must be satisfied by at least one value"
    Matcher<Value> valueMatcher
) 
        given Value satisfies Object 
        => HasValueMatcher<Value>(valueMatcher) ;


"Creates a matcher for {@link java.util.Map}s matching when the examined {@link java.util.Map} contains
 at least one entry whose key satisfies the specified <code>keyMatcher</code> <b>and</b> whose
 value satisfies the specified <code>valueMatcher</code>.
 
 For example:
 assertThat(HashMap{\"f\"->\"foo\", \"b\"->\"bar\"}, HasEntryMatcher(eq(\"b\"), eq(\"bar\")));
 "
shared class HasEntryMatcher<Key=Object, Value=Object>(
    "the key matcher that, in combination with the valueMatcher, must be satisfied by at least one entry"
    Matcher<Key> keyMatcher,
    "the value matcher that, in combination with the keyMatcher, must be satisfied by at least one entry"
    Matcher<Value> valueMatcher,
    "Descriptor for found key and value."
    Descriptor descriptor = DefaultDescriptor()
) 
        satisfies TypeSafeCombinableMatcher<Map<Key, Value>> 
        given Key satisfies Object 
        given Value satisfies Object 
{
    shared actual Boolean typeSafeMatch(Map<Key,Value> actual) {
        for(key->val in actual) {
            if(keyMatcher.match(key) && valueMatcher.match(val)) {
                return true;
            }
        }
        return false;
    }
    
    shared actual Description typeSafeExplainFully(Map<Key,Value> actual, Descriptor descriptor) {
        variable Boolean matched = false;
        
        value descriptionSb = ArrayList<Description>();  
        for(key->val in actual) {
            Boolean entryMatched = keyMatcher.match(key) && valueMatcher.match(val); 
            if(entryMatched) {
                matched = true;
            }
            
            Description keyMatchDescr = keyMatcher.explainFully(key, descriptor);
            Description valueMatchDescr = valueMatcher.explainFully(val, descriptor);
            Description entryDescr = Description(
                entryMatched then "Entry matched" else "Entry did not match", [
                    Description("Key:   ", [keyMatchDescr]),
                    Description("Value: ", [valueMatchDescr])
                ],
                entryMatched then noHighlight else errorHighlight
            ); 
            descriptionSb.add(entryDescr);
        }    
        
        value result = Description(
            matched 
                then "An entry matched" 
                else "No entry matched", 
            
            descriptionSb.sequence(),
            matched then noHighlight else errorHighlight
        );
        return result;
        
    }


    shared actual void describeTo(TextBuilder textBuilder) 
        => textBuilder
        .appendText("has entry [")
        .appendDescriptionOf(keyMatcher)
        .appendText(" -> ")
        .appendDescriptionOf(valueMatcher)
        .appendText("]")
    ;

    shared actual void typeSafeDescribeActual(Map<Key,Value> actual, TextBuilder textBuilder) 
            => dumpMap(actual, textBuilder);
    
    
    
}

"Creates a matcher for {@link java.util.Map}s matching when the examined {@link java.util.Map} contains
 at least one entry whose key satisfies the specified <code>keyMatcher</code> <b>and</b> whose
 value satisfies the specified <code>valueMatcher</code>.
 
 For example:
 assertThat(HashMap{\"f\"->\"foo\", \"b\"->\"bar\"}, hasEntry(eq(\"b\"), eq(\"bar\")));
 "
shared HasEntryMatcher<Key, Value> hasEntry<Key, Value>
        (
    "the key matcher that, in combination with the valueMatcher, must be satisfied by at least one entry"
    Matcher<Key> keyMatcher,
    "the value matcher that, in combination with the keyMatcher, must be satisfied by at least one entry"
    Matcher<Value> valueMatcher
) 
        given Key satisfies Object 
        given Value satisfies Object 
        => HasEntryMatcher<Key, Value>(keyMatcher, valueMatcher) ;



