
//"Parser for a single argument and a single option.
// "
//shared interface SingleArgAndOptionParser {
//	
//	
//	
//	shared formal Accepted|Error|Ignored nextArg(
//		/*Values values, */Cursor cursor
//	);
//	
//}


shared class StepParser_old<Value>(
	BoundOption[] singleArgParsers,
	Error?(Cursor)(Value) lastArgsHandler// = (CommandValue values)(Cursor cursor) => Error("Command ``names``: Unexpected aguments at ``cursor.first``")
) 
{
	//shared Error|Accepted parseStep(Cursor cursor) {
		
		
		shared Accepted|Error next(Cursor cursor, Value values) {
			
			for(p in singleArgParsers) {
				switch(res = p.parseArgument(cursor))
				case(is Ignored) {}
				case(is Error) {return res;}
				case(is Accepted) {return res;}
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

	//}
}

