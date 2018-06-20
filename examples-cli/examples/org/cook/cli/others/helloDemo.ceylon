import org.cook.cli {
	BooleanOption,
	Error,
	StringOption,
	Parser,
	Cursor
}
import ceylon.collection {
	ArrayList
}
"Most basic usage: 
 
 	-h, --help
 	--target <string>
 	[sources *]
 
 "
shared void helloDemo() {
	
	""
	class AppSettings() {
		shared variable Boolean help = false;
		shared Error? doSetHelp() {help = true; return null;}
		
		shared variable String? target = null;	// null for 'not set'
		shared Error? doSetTarget(String val) {target = val; return null;}
		
		shared ArrayList<String> sources = ArrayList<String>(); 
		shared Error? appendSources({String *}s) {sources.addAll(s); return null;}
	}
	
	value helpOption = BooleanOption<AppSettings> (["-h", "--help"], AppSettings.doSetHelp);
	value targetOption = StringOption<AppSettings>(["-t", "--target"], AppSettings.doSetTarget);
	"Handle last "
	Error? lastArgsHandler(AppSettings appSettings)(Cursor cursor) 
		=> appSettings.appendSources(cursor.args);
	
	
	Parser<AppSettings> parser = Parser<AppSettings>(AppSettings, 
		{
			helpOption, 
			targetOption
		},
		lastArgsHandler
	); 
	
	
	// -- 
	
	AppSettings|Error res = parser.parse(["-h", "-t", "target", "source0", "soource1", "source2"]); 
	if(is Error res) {
		res.printIndented(process.writeErrorLine);
	} else {
		// print "help:true, target:target, sources:{ source0, soource1, source2 }"
		print("help:``res.help``, target:``res.target else "<null>"``, sources:``res.sources``");
	}
	
}
