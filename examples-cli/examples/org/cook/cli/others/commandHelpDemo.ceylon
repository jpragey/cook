import ceylon.collection {
	LinkedList
}

import org.jpragey.ceylon.cli {
	BooleanOption,
	Error,
	Parser,
	Cursor,
	Bindable,
	CommandOption,
	BindableWithHelp
}
"
 "
shared void commandHelpDemo() {
	
	"'command' option values."
	class MyCommandValues() {
		"'--help' option found in 'command' command"
		shared variable Boolean help = false;
		shared Error? doSetHelp() {help = true; return null;}
		
		//shared actual String string => "[]";
	}
	
	"'help' option values. All terms following on CLI are topics."
	class HelpCommandValues() {
		""
		shared LinkedList<String> topics = LinkedList<String>();
		//shared Error? addTopics({String *} topics) {this.topics.addAll(topics); return null;}
		"Set add all cursor arguments to [[HelpCommandValues.topics]].
		 Note that its signature [Error? (Cursor)] makes it a valid candidate for a last arguments handler."
		shared Error? addTopics(Cursor topics) {this.topics.addAll(topics.args); return null;}
	}
	
	"Application settings. It know '--help' option and 'help' and 'command' command."
	class AppSettings() {
		"'--help' option found globally (before any (or without) command)."
		shared variable Boolean help = false;
		shared Error? doSetHelp() {help = true; return null;}
		
		"'command' command settings, if any."
		shared variable MyCommandValues? myCommandValues = null;
		"'command' settings factory, called when 'command' CLI arg is parsed. 
		 We must keep it somewhere (in [[myCommandValues]] here, but may be anywhere), as the framework won't do it for us."
		shared MyCommandValues createCommandValues() => this.myCommandValues = MyCommandValues();
		
		"'help' command."
		shared variable HelpCommandValues? helpCommandValues = null;
		"'help' command factory, called when 'help' CLI arg is parsed.
		 The created [[HelpCommandValues]] is stored in this.[[helpCommandValues]]. 
		 "
		shared HelpCommandValues createHelpCommand() => this.helpCommandValues = HelpCommandValues();
	}
	
	// -- Help classes; we separate simple options and command help classes.
	interface HelpTopic {
		shared formal actual String string;
	}
	class OptionHelpTopic(shared actual String string) 
			satisfies HelpTopic
	{}
	class CommandHelpTopic(shared String shortDescription, shared String longDescription) 
			satisfies HelpTopic 
	{
		shared actual String string => shortDescription;
	}

	
	"Create '--help' options. It's not a constant because it's used both globally and for 'command' command,
	 so the setter changes."
	//BooleanOption<Values, HelpTopic> 
	BindableWithHelp<Values, HelpTopic>//<Values, HelpTopic> 
		makeHelpOption<Values>(Error?(/*Boolean*/)(Values) setter) =>
			BooleanOption<Values/*, HelpTopic*/> (
		["-h", "--help"], 
		setter
		//, 
		//OptionHelpTopic(
		//	"""-h, --help:
		//	                   Print some help and exit""")
	).withHelp(
		OptionHelpTopic(
			"""-h, --help:
			                   Print some help and exit""")
		
	);
	
	
	"'help', as command"
	value helpCommandOption = CommandOption{ // in fact CommandOption<AppSettings, HelpCommandValues, CommandHelpTopic>
		names = "help"; 
		createValues = (AppSettings values)  => values.createHelpCommand(); 
		bindOptions = {};
		//auxiliary = CommandHelpTopic(
		//	"help:     Global help on application.",
		//	"help:     Global help on application (long description).");
		lastArgsHandler =  HelpCommandValues.addTopics;
	}.withHelp(CommandHelpTopic(
			"help:     Global help on application.",
			"help:     Global help on application (long description)."));
	
	
	"'command', as command"
	value myCommandOption = CommandOption( // in fact CommandOption<AppSettings, MyCommandValues, CommandHelpTopic, HelpTopic>
		"command", 
		(AppSettings values)  => values.createCommandValues(), 
		{
			makeHelpOption(MyCommandValues.doSetHelp)	// 'command --help'
		}//,
		//CommandHelpTopic(
		//	"command : application specific command.",
		//	"command : application specific command (long description)."
		//)
	).withHelp(CommandHelpTopic(
			"command : application specific command.",
			"command : application specific command (long description)."
		));
			
	
	
	//
	//value targetOption = StringOption<AppSettings, HelpTopic>(
	//	["-t", "--target"], 
	//	AppSettings.doSetTarget, 
	//	HelpTopic(
	//		"""-t, --target:
	//		                   Set the target file""")
	//);
	
	"Handle last arguments (if there is no command)"
	Error? lastArgsHandler(AppSettings appSettings)(Cursor cursor) 
		=> Error("Unexpected arguments starting at ``cursor.first``");
	
	{BindableWithHelp<AppSettings, HelpTopic> *} mainOptionList = {
		makeHelpOption(AppSettings.doSetHelp),	// '--help'
		helpCommandOption,						// 'help' command
		myCommandOption							// 'command' command
	};
	// Create main parser
	Parser<AppSettings/*, HelpTopic*/> parser = Parser<AppSettings/*, HelpTopic*/>(AppSettings, 
		mainOptionList,
		lastArgsHandler
	); 
	
	
	
	
	void printGlobalHelp({Bindable<AppSettings> *} globalOptions, void print(String text)) {
		
		HelpTopic?[] optionTopics = globalOptions
				.narrow<BindableWithHelp<AppSettings,HelpTopic>>()
				*.help;
		
		print(
			"USAGE: ceylon run [--] `` `module`.qualifiedName `` [OPTIONS] <command> [COMMAND_OPTIONS]
			 
			 OPTIONS:
			 `` "\n".join(optionTopics.narrow<OptionHelpTopic>()) ``
			 
			 COMMANDS:
			 `` "\n".join(optionTopics.narrow<CommandHelpTopic>()) ``
			 
			 For help on a command, try:
			      ceylon run `` `module`.qualifiedName `` help <command>
			 "
		);
	}
	
	void printCommandHelp({Bindable<AppSettings> *} globalOptions, String commandName, void print(String text)) {
		
		void printFullHelp(String longDescr, {OptionHelpTopic*} subOptions) {
			print(
				"COMMAND
				     `` longDescr ``
				 	 
			 	OPTIONS:
			 	`` "\n".join(subOptions*.string)``
				 	 ");
		}
		
		for(Bindable<AppSettings> option in globalOptions) {
			if(is CommandOption<AppSettings, Anything> commandOption = option.effectiveOption, commandOption.names.contains(commandName)) {
				String longDescr = if(is BindableWithHelp<AppSettings, CommandHelpTopic> option) 
					then option.help.longDescription
				 	else "(No command help found)";
				
				printFullHelp(longDescr, commandOption.subOptionsHelp<OptionHelpTopic>());
			}
		}
	}	

	void dispatchHelp(AppSettings appSettings, void print(String text)) {
		if(exists helpSettings = appSettings.helpCommandValues) {
			
			if(nonempty topics = helpSettings.topics.sequence()) {	// 'help <topics>...'
				
				for(topic in topics) {
					printCommandHelp(parser.bindOptions, topic, print);
				}
			} else {	// 'help' without topic, print global help
				printGlobalHelp(parser.bindOptions, print);
			}
			
		} else {
			print("-- Not an 'help topic...' arg list");
		}
	}

	// -- examples
	void examplePrintHelp(String[] args) {
		
		print("========= Parsing CLI arguments ``args`` ==============");
		AppSettings|Error res = parser.parse(args); 
		if(is Error res) {
			res.printIndented(process.writeErrorLine);
		} else {
			dispatchHelp(res, process.writeLine);
		}
	}
	
	examplePrintHelp(["help"]);
	examplePrintHelp(["help", "command"]);
	examplePrintHelp(["help", "help"]);
	examplePrintHelp(["help", "unknownCommand"]);
	examplePrintHelp(["help", "command", "unknownCommand"]);

	
}
