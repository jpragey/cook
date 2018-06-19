

shared void run() {
	
	class CommandValues() {
		shared variable String source = "";
		shared actual String string => "[source:'``source``']";
	}
	class AppValues() {
		shared variable String source = "";
		
		shared Error? doSetSource(String s) {source = s; return null;}
		
		shared variable Boolean help = false;
		shared Null doSetHelp(/*Boolean help*/) {this.help = true; return null;}
		//shared Error? setHelp(String arg) {
		//    if(arg=="true") {help = true; return null;}
		//    if(arg=="false") {help = true; return null;}
		//    return Error("'true' or 'false' expected."); 
		//}
		
		shared variable CommandValues? commandValues = null;
		shared CommandValues createCommandValues() {
			CommandValues cv = CommandValues();
			commandValues = cv;
			return cv;
		}
		shared actual String string => "help:``help``, source:'``source``', command:``commandValues?.string else "<null>"``";
	}
	
	//StringOption<AppValues> helpOption = StringOption<AppValues>(["-h", "--help"], (appValue, arg) => appValue.setHelp(arg)); 
	BooleanOption<AppValues> helpOption = BooleanOption<AppValues>(["-h"], AppValues.doSetHelp);  
	
	StringOption<Values> makeSourceOption<Values>(<Error?(String)(Values) > setter) 
			=> StringOption<Values>(["--str"], setter);
	//
	//StringOption<AppValues> appSourceOption = makeSourceOption<AppValues>((AppValues values)(String s) {values.source = s;return null;});
	//StringOption<AppValues> appSourceOption2 = makeSourceOption<AppValues>(AppValues.doSetSource);
	
	StringOption<CommandValues> commandSourceOption = makeSourceOption<CommandValues>((CommandValues values)(String s) {values.source = s;return null;});
	
	value commandOption = CommandOption<AppValues, CommandValues>(
		"command", 
		(AppValues values)  => values.createCommandValues(), 
		{
			commandSourceOption
		}
	);
	
	
	Parser<AppValues> parser = Parser<AppValues>(AppValues, {
		makeSourceOption(AppValues.doSetSource),
		helpOption,
		commandOption
	});
	
	//switch(res = parser.parse([]))
	//case(is Error) {}
	//case(is AppValues) {}
	
	AppValues|Error res = parser.parse(["-h", "--str", "globalSource", "command", "--str", "commandSource"]); 
	if(is Error res) {
		res.printIndented(process.writeErrorLine);
	} else {
		print(res);
	}
}