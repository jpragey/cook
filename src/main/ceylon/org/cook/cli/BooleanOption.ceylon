shared class BooleanOption<Values/*, Aux=Null*/>(
	String[] names, /*<Error? (Values, Boolean)>*/ 
	Error?()(Values) setter
	//,
	//shared actual Aux? auxiliary = null
) 
		satisfies Bindable <Values/*, Aux*/> 
{
	shared actual BoundOption bind(Values values) => object satisfies BoundOption {
		
		shared actual Accepted|Ignored|Error parseArgument(Cursor cursor) {
			String arg = cursor.first;
			if(arg in names) {
				//return setter(values)() else Accepted(cursor.advance(1)/*, null*/);
				return setter(values)() else Accepted(cursor.advance(1)/*, null*/);
			}
			return Ignored(arg);
		}
		//shared actual Values values => values_;
		shared actual String string => "BoundOption[``names``]";
	};
	shared actual String string => "BooleanOption[``names``]";
}