import ceylon.collection {
	ArrayList
}

import org.jpragey.ceylon.cli {
	BooleanOption,
	Error,
	StringOption,
	Parser,
	Cursor
}
"Most basic usage: 
 
 	-h, --help
 	--target <string>
 	[sources *]
 
 "
shared void helpDemo() {
	
	""
	class AppSettings() {
		shared variable Boolean help = false;
		shared Error? doSetHelp() {help = true; return null;}
		
		shared variable String? target = null;	// null for 'not set'
		shared Error? doSetTarget(String val) {target = val; return null;}
		
		shared ArrayList<String> sources = ArrayList<String>(); 
		shared Error? appendSources({String *}s) {sources.addAll(s); return null;}
	}
	
	class HelpTopic(shared actual String string) {}
	
	
	value helpOption = BooleanOption<AppSettings> (
		["-h", "--help"], 
		AppSettings.doSetHelp
		).withHelp(HelpTopic(
			"""-h, --help:
			                   Print some help and exit"""));
	
	value targetOption = StringOption<AppSettings>(
		["-t", "--target"], 
		AppSettings.doSetTarget 
	).withHelp(HelpTopic(
			"""-t, --target:
			                   Set the target file"""));
	
	value options = {
			helpOption, 
			targetOption
		}; 
	"Handle last "
	Error? lastArgsHandler(AppSettings appSettings)(Cursor cursor) 
		=> appSettings.appendSources(cursor.args);
	
	
	Parser<AppSettings> parser = Parser<AppSettings>(AppSettings, 
		options,
		lastArgsHandler
	); 
	
	
	// -- 
	
	AppSettings|Error res = parser.parse(["-h", "-t", "target", "source0", "source1", "source2"]); 
	if(is Error res) {
		res.printIndented(process.writeErrorLine);
	} else {
		// print "help:true, target:target, sources:{ source0, soource1, source2 }"
		print("help:``res.help``, target:``res.target else "<null>"``, sources:``res.sources``");
		
		if(res.help) {
			print(
				"demo [OPTIONS] source...
				 Options:
				 ``
					// Retrieve help data by parser.bindOptions [[auxiliary]] fields
					//"\n".join([
					//	for(opt in options) 
					//		opt.help
					//		/*else "<missing doc for option ``opt``>"*/])
					//``
				"\n".join(options*.help)
				``

			       ");
		}

		
	}
	
}
