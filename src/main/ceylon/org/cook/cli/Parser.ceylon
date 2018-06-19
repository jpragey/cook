
shared class Parser<Values /*, Aux=Null*//*, Help=String*/> 
//	given BindableList satisfies {Bindable<Values, Aux> *}
{
	Values | <Values()> createValues;
	shared {Bindable<Values/*, Aux*/> *} bindOptions;
	Error?(Cursor)(Values) lastArgsHandler;
	
	shared new (Values | <Values()> createValues, {Bindable<Values/*, Aux*/> *} bindOptions, Error?(Cursor)(Values) lastArgsHandler = (Values values)(Cursor cursor) => Error("Unexpected aguments at ``cursor.first``")) {
		this.createValues = createValues;
		this.bindOptions = bindOptions;
		this.lastArgsHandler = lastArgsHandler;
	}

	//shared new withHelp(Values | <Values()> createValues, BindableList bindOptions, Error?(Cursor)(Values) lastArgsHandler = (Values values)(Cursor cursor) => Error("Unexpected aguments at ``cursor.first``")) {
	//	this.createValues = createValues;
	//	this.bindOptions = bindOptions;
	//	this.lastArgsHandler = lastArgsHandler;
	//}
	
	Values doCreateValues() => if(is Values createValues) then createValues else createValues(); 
	
	shared Error|Values parse(String[] args) {
		
		if(nonempty args) {
			Cursor cursor = Cursor(args);
			Error|Values values = parseFromCursor(cursor);
			return values;
		} else {
			return doCreateValues();
		}
	}
				
	
	shared Error|Values parseFromCursor(variable Cursor initialCursor) {
		Values values = doCreateValues();
		
		//if(nonempty args) {
			BoundOption [] bindings = bindOptions*.bind(values);
			//{BoundOption *} bindings = if(is <{BoundOption *}(Values)> bindOptions) 
			//then bindOptions(values)
			//else bindOptions*.bind(values);

//			value stepParser = StepParser<Values>(bindings, lastArgsHandler);
			
			Accepted|Error next(Cursor cursor, Values values) {
				
				for(p in bindings) {
					switch(res = p.parseArgument(cursor))
					case(is Ignored) {}
					case(is Error|Accepted) {return res;}
				}
				
				// If we reach here, all parsers ignored the arg; thus run last args handler.
				switch(lastArgResult = lastArgsHandler(values)(cursor))
				case(is Error) {return lastArgResult;}
				case(is Null) {
					return Accepted(null/*, null*/);
				}
				
				//for(boundParser in bindings) {
				//	Accepted|Error|Ignored result = boundParser.parseArgument(cursor);
				//	switch(result)
				//	case(is Accepted|Error) {return result;}
				//	case(is Ignored) {}
				//}
				//return Ignored(cursor.first);
			}

			
			
			//object mainArgParser satisfies SingleArgParser {
			//	shared actual Accepted|Error|Ignored nextArg(Cursor cursor) {
			//		for(boundParser in bindings) {
			//			Accepted|Error|Ignored result = boundParser.parseArgument(cursor);
			//			switch(result)
			//			case(is Accepted|Error) {return result;}
			//			case(is Ignored) {}
			//		}
			//		return Ignored(cursor.first);
			//	}
			//}
			//
			//variable SingleArgParser currentArgParser = mainArgParser;
			//
			//variable Error[] errors = [];
			
			variable Cursor? cursor = initialCursor;
			while(exists c = cursor) {
				switch(result = /*stepParser.*/next(c, values))
				case(is Error) {return result;}
				case(is Accepted) {
					cursor = result.nextCursor;
				}
				//
				//switch(result = currentArgParser.nextArg(c))
				//case(is Error) {
				//	return result;
				//	//errors = errors.append([result]); cursor = c.advance(1); 
				//	//break;
				//} 
				//case(is Accepted) {
				//	cursor = result.nextCursor;
				//	if(exists nextParser = result.nextParser) {
				//		currentArgParser = nextParser;
				//	}
				//}
				//case(is Ignored) {
				//	if(exists lastArgsError = lastArgsHandler(values)(c) ) {
				//		return lastArgsError;
				//		//errors = errors.append([lastArgsError]);
				//	}
				//	//cursor = c.advance(1);
				//	break;
				//}
			}
		//}
		
		return values;
	}
	
	//shared T? findOptionWithHelp<Help, T> (
	//	T? filter(BindableWithHelp<Values, Help> v)
	//) given T satisfies BindableWithHelp<Values, Help> 
	//{
	//	for(Bindable<Values> option in bindOptions) {
	//		//print("> option: ``type(option)``");
	//		//Bindable<AppSettings> effectiveOption = if(is BindableWithHelp<AppSettings, CommandHelpTopic> option) then option.delegate else option;
	//		//Bindable<AppSettings> effectiveOption = option.effectiveOption;
	//		
	//		
	//		if(is BindableWithHelp<Values, Help> option, exists r = filter(option)) {
	//			return r;
	//		}
	//		
	//	}
	//	return null;
	//}
	
}