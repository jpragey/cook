shared class CommandOption<Values, out CommandValue/*, out SubOptionHelp=Null*/>(
	shared String names, 
	CommandValue(Values) createValues, 
	{Bindable<CommandValue/*, SubOptionHelp*/> *} bindOptions = {},
	"Help on this CommandOption"
	//shared actual Aux? auxiliary = null,
	Error?(Cursor)(CommandValue) lastArgsHandler = (CommandValue values)(Cursor cursor) => Error("Command ``names``: Unexpected aguments at ``cursor.first``")
) 
		satisfies Bindable <Values/*, Aux*/>
{
	
//	print("SubOptionsHelp: ``type``");
	
//	shared {SubOptionHelp *} subOptionsHelp => bindOptions.narrow<BindableWithHelp<CommandValue, SubOptionHelp>>()*.help;
	
	shared {SubOptionHelp *} subOptionsHelp<SubOptionHelp>() => 
			bindOptions.narrow<BindableWithHelp<CommandValue, SubOptionHelp>>()*.help;
	
//	value commandHelps = bindOptions.narrow<BindableWithHelp<CommandValue, SubOptionHelp>>()*.help;
	

	//shared {SubOptionHelp? *} subOptionsHelp => bindOptions*.auxiliary;
	
	shared actual BindableWithHelp<Values, Help> /*& WithChildrenHelp <SubOptionHelp>*/ withHelp<Help>(Help help_) => 
			object satisfies BindableWithHelp<Values, /*Aux, */Help> //& WithChildrenHelp <SubOptionHelp> 
			{
		shared actual BoundOption bind(Values values) => outer.bind(values);
		
		shared actual Help help => help_;
		
		shared actual Bindable<Values> delegate => outer;
		
		//shared actual {SubOptionHelp*} childrenHelp => outer.subOptionsHelp;
		
		
		
		//		shared actual Aux? auxiliary => outer.auxiliary;
		
	};

	
	
	shared actual BoundOption bind(Values values) => object satisfies BoundOption {
		shared actual Accepted|Ignored|Error parseArgument(Cursor cursor) {
			String arg = cursor.first;
			if(arg == names) {
				
				CommandValue commandValue = createValues(values);
				
				if(exists commandCursor = cursor.advance()) {
					
					value parser = Parser<CommandValue/*, SubOptionHelp*/>(
						commandValue, 
						bindOptions,
						lastArgsHandler 
					) ;
					
					Error|CommandValue res = parser.parseFromCursor(commandCursor);
					switch(res)
					case(is Error) {return res;}
					else {
						return Accepted(null);
					}
				}
				
				return Accepted(null);	// Nothing after command name
			}
			return Ignored(arg);
		}
	};
}