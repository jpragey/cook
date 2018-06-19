shared class PropertyOption<Values/*, Aux=Null*/>(
	shared String prefix, 
	Error?(String, String)(Values) setter,  
	shared String separator="="
	//,
	//shared actual Aux? auxiliary = null
) satisfies Bindable <Values/*, Aux*/> {
	shared actual BoundOption bind(Values values) => object satisfies BoundOption {
		shared actual Accepted|Ignored|Error parseArgument(Cursor cursor) {
			String arg = cursor.first;
			
			if(arg.startsWith(prefix)) {
				
				String afterPrefix = arg[prefix.size...];
				
				if(exists separatorPos = afterPrefix.firstInclusion(separator)) {   // key=value
					String key = afterPrefix[0:separatorPos];
					String val = afterPrefix[separatorPos + separator.size ...];
					return setter(values)(key, val) else Accepted(cursor.advance(1)/*, null*/);
				} else {
					return Error("Property \"``afterPrefix``\": value expected (after separator \"``separator``\" ).");
				}
			} else {
				return Ignored(arg);
			}
		}
		
		
	};
	
}