shared class StringOption<Values> 
		satisfies Bindable <Values/*, Aux*/> 
{
	String[] names;
	Error?(String)(Values) setter;
	//shared actual Aux? auxiliary;
	
	shared new (String[] names, Error?(String)(Values) setter/*, Aux? auxiliary = null*/) {
		this.names = names;
		this.setter = setter;
		//this.auxiliary = auxiliary;
	}
	shared new nocheck(String[] names, Anything(String)(Values) setter/*, Aux? auxiliary = null*/) {
		this.names = names;
		this.setter = (Values v)(String s) {setter(v)(s); return null;};
		//this.auxiliary = auxiliary;
	}

	shared actual BoundOption bind(Values values) => object satisfies BoundOption {
		
		shared actual Accepted|Ignored|Error parseArgument(Cursor cursor) {
			String arg = cursor.first;
			if(arg in names) {
				if(exists n = cursor.lookahead(1)) {
					return setter(values)(n) else Accepted(cursor.advance(2)/*, null*/);
				}
				return Error("Argument of ``arg`` expected.");
			}
			return Ignored(arg);
		}
		//shared actual Values values => values_;
		
	};
	
	shared actual String string => "StringOption``names``";
}