import org.cook.cli {
	Error,
	BooleanOption,
	StringOption,
	CommandOption,
	Parser,
	PropertyOption,
	Cursor
}
import ceylon.collection {
	HashMap,
	LinkedList
}

shared void commandDemo() {
	
	class CommandValues() {
		shared variable String source = "";
		shared HashMap<String, String> properties = HashMap<String, String>();
		shared Error? addProperty(String key, String item) {properties.put(key, item); return null;}
		
		shared LinkedList<String> lastArgs = LinkedList<String>();
		shared Null addLastArgs({String *} lastArg) {lastArgs.addAll(lastArg); return null;}

		shared actual String string => "[source:'``source``', properties:``properties``, last args:``lastArgs``]";
	}
	class AppValues() {
		shared variable String source = "";
		
		shared Error? doSetSource(String s) {source = s; return null;}
		
		shared variable Boolean help = false;
		shared Error? doSetHelp() {this.help = true; return null;}
		
		shared variable CommandValues? commandValues = null;
		shared CommandValues createCommandValues() {
			CommandValues cv = CommandValues();
			commandValues = cv;
			return cv;
		}
		shared HashMap<String, String> properties = HashMap<String, String>();
		shared Error? addProperty(String key, String item) {properties.put(key, item); return null;}
		
		shared actual String string => "help:``help``, source:'``source``', properties:``properties``, command:``commandValues?.string else "<null>"``";
	}
	
	//StringOption<AppValues> helpOption = StringOption<AppValues>(["-h", "--help"], (appValue, arg) => appValue.setHelp(arg)); 
	BooleanOption<AppValues> helpOption = BooleanOption<AppValues>(["-h"], AppValues.doSetHelp);
	PropertyOption<Values> propertyOption<Values>(Error?(String,String)(Values) append) => PropertyOption<Values>("-D", append /*AppValues.addProperty*/);
	
	StringOption<Values> makeSourceOption<Values>(<Error?(String)(Values) > setter) 
			=> StringOption<Values>(["--str"], setter);
	
	//StringOption<AppValues> appSourceOption = makeSourceOption<AppValues>((AppValues values)(String s) {values.source = s;return null;});
	value appSourceOption = makeSourceOption(AppValues.doSetSource);
	
	StringOption<CommandValues> commandSourceOption = makeSourceOption<CommandValues>((CommandValues values)(String s) {values.source = s;return null;});
	
	value commandOption = CommandOption<AppValues, CommandValues>(
		"command", 
		(AppValues values)  => values.createCommandValues(), 
		{
			propertyOption(CommandValues.addProperty),
			commandSourceOption
		},
		//null,	// aux
		(CommandValues commandValues)(Cursor cursor) {commandValues.addLastArgs(cursor.args); return null;}
	);
		
		
		Parser<AppValues> parser = Parser<AppValues>(AppValues, {
			appSourceOption,
			//makeSourceOption(AppValues.doSetSource),
			helpOption,
			propertyOption(AppValues.addProperty),
			commandOption
		});
		
		//switch(res = parser.parse([]))
		//case(is Error) {}
		//case(is AppValues) {}
		
		AppValues|Error res = parser.parse([
			"-h", "--str", "globalSource", "-Dprop0=Property0", "-Dprop1=Property1", 
			"command", "--str", "commandSource", "-Dprop2=Property2", "-Dprop3=Property3", "lastArg0", "lastArg1"
		]); 
		if(is Error res) {
			res.printIndented(process.writeErrorLine);
		} else {
			print(res);
		}
	}