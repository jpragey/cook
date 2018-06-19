import org.jpragey.ceylon.cli {
	Error,
	StringOption,
	Parser,
	Cursor,
	BindableWithHelp,
	BooleanOption
}

"Help data associated with an option"
class HelpData(shared String shortHelp/*, shared String longHelp*/) {
	
}

class JavacValues() {
	
	shared variable String? classPath = null;	// null for 'not set'
	shared Error? setClassPath(String val) {
		classPath = val; 
		return null;
	}
	
	shared variable Boolean help = false;
	shared Error? doSetHelp() {
		help=true; 
		return null;
	}
	
	"Last arguments are the source files; we validate the '.java' extension."
	shared variable String [] sources = []; 
	shared Error? appendSources([String *] javaFiles) {
		// Validate file names - they must end by '.java'
		if(nonempty bogusFileNames = javaFiles.select((String fn) => !fn.endsWith(".java"))) {
			return Error("File names must terminate by '.java: ``bogusFileNames``'");
		}
		sources = sources.append<String>(javaFiles); 
		return null;
	}
}

shared void run() {

	// -- Note : we add HelpData here
	//Note it's a BindableWithHelp<JavacValues, Nothing, HelpData>
	value classpathOption = StringOption(["-cp", "-classpath"], JavacValues.setClassPath)
			.withHelp(HelpData("-cp <path> or -classpath <path>: specifies where to find user class files"));
	
	// -- Create an help option
	BindableWithHelp<JavacValues, /*Nothing, */HelpData>
			helpOption = BooleanOption(["-h", "-help"], JavacValues.doSetHelp 
		).withHelp(HelpData {
			shortHelp = "-h, --help : print help and exit"; 
		});
			
	"Last arguments handler (manages source files here)"
	Error? lastArgsHandler(JavacValues appValues)(Cursor cursor) 
			=> appValues.appendSources(cursor.args);
	
	value allOptions = {classpathOption, helpOption}; 
	
	// Note: added HelpData parameter
	Parser<JavacValues> parser = Parser<JavacValues> {
		createValues = JavacValues;
		bindOptions = allOptions /*{classpathOption, helpOption}*/;
		lastArgsHandler = lastArgsHandler;
	}; 
	//Parser<JavacValues, HelpData, {BindableWithHelp<JavacValues, Nothing, HelpData>* }> parser = Parser<JavacValues, HelpData, {BindableWithHelp<JavacValues, Nothing, HelpData>* }> {
	//	createValues = JavacValues;
	//	bindOptions = bo /*{classpathOption, helpOption}*/;
	//	lastArgsHandler = lastArgsHandler;
	//}; 
	//
	//{Bindable<JavacValues, HelpData>* } parserOptions0 = parser.bindOptions;
	//{BindableWithHelp<JavacValues, Nothing, HelpData>* }parserOptions = parser.bindOptions;
	
	void printHelp({HelpData *} helpDatas, Anything (String ) write = print) {
		write("""javac - Reads Java class and interface definitions and compiles them into bytecode and class files.""");
		for(h in helpDatas) {
			write("  ``h.shortHelp``");
		}
		write(
				"""SEE ALSO
				   · java(1)""");
	}
	
	void parseAndExecute(String[] args) {
		switch(JavacValues|Error javacValues = parser.parse(args))
		case (is JavacValues) {
			if(javacValues.help) {
				//printHelp(parser.bindOptions*.auxiliary);
				printHelp(allOptions*.help);
			}
			//print("Application config: ``appConfig``");
		}
		case (is Error) {
			javacValues.printIndented(process.writeErrorLine);
		}
	}
	
	parseAndExecute(["-h"]);
	parseAndExecute(["-cp", "./lib/mylib.jar"]);

	
	//
	//
	//
	//JavacValues|Error settings = parser.parse([
	//	"-cp", "some/class/path", 
	//	"source0.java", "soource1.java", "source2.java"]);
	// 
	//if(is Error settings) {
	//	settings.printIndented(process.writeErrorLine);
	//} else {
	//	// print "help:true, target:target, sources:{ source0, soource1, source2 }"
	//	print("CLI args OK: classPath:``settings.classPath else "<not set>"``, sources:``settings.sources``");
	//}
	
}
