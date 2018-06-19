shared interface TextBuilder {
    shared formal TextBuilder appendText(String text);
    shared formal TextBuilder appendNewLine();
    shared formal TextBuilder appendValue<T>(T/*?*/ val /*, Descriptor descriptor*/) /*given T satisfies Object*/;
    shared formal TextBuilder appendValueList/*<T>*/(String start, String separator, String end, Anything* values);//  given T satisfies Object;
    shared formal TextBuilder appendList(String start, String separator, String end, {SelfDescribing *} values);
    shared formal TextBuilder appendDescriptionOf(SelfDescribing val);
    
    shared default TextBuilder appendOptionalValue(Anything val /*, Descriptor descriptor*/) {
        if(exists val) {
            appendValue(val);
        } else {
            appendText("<null>");
        }
        return this;
    }
}

shared class DefaultTextBuilder(shared Descriptor descriptor) satisfies TextBuilder {
    StringBuilder stringBuilder = StringBuilder();
    
    shared actual TextBuilder appendDescriptionOf(SelfDescribing val) {
        val.describeTo(this);
        return this;
    }
    
    shared actual TextBuilder appendText(String text) {
        stringBuilder.append(text);
        return this;
    }
    shared actual TextBuilder appendNewLine() {
        stringBuilder.append(operatingSystem.newline);
        return this;
    }
    
    shared actual TextBuilder appendValue<T>(T/*?*/ val)  /*given T satisfies Object*/ {
        String text = descriptor.describe(val, descriptor);
        stringBuilder.append(text);
        return this;
    }
    
    TextBuilder makeList(String start, String separator, String end, {Anything(DefaultTextBuilder) *} values) {
        stringBuilder.append(start);
        
        variable Boolean first = true;
        for(val in values) {
            if(first) {
                first = false;
            } else {
                stringBuilder.append(separator);
            }
            val(this);
            //val.describeTo(this);
        }
        stringBuilder.append(end);
        return this;
    }
    
    shared actual TextBuilder appendList(String start, String separator, String end, {SelfDescribing*} values) {
        makeList(start, separator, end, {
            for(val in values) (DefaultTextBuilder mtb) =>
                    val.describeTo(mtb)
        });
        return this;
    }
    
    shared actual TextBuilder appendValueList(String start, String separator, String end, Anything * values)
    //given T satisfies Object
    {
        makeList(start, separator, end, {
            for(val in values) (DefaultTextBuilder mtb) =>
                    mtb.appendValue(val else "<null>")
        });
        return this;
    }
    
    shared actual String string => stringBuilder.string;
}
