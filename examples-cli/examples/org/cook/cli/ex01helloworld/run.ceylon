import org.jpragey.ceylon.cli {
	Error,
	StringOption,
	Parser,
	Cursor
}


class JavacValues() {
	
	shared variable String? classPath = null;	// null for 'not set'
	shared Error? setClassPath(String val) {
		classPath = val; 
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

	// -- Create options
	value classpathOption = StringOption(["-cp", "-classpath"], JavacValues.setClassPath);
	
	"Last arguments handler (manages source files here)"
	Error? lastArgsHandler(JavacValues appValues)(Cursor cursor) 
			=> appValues.appendSources(cursor.args);
	
	Parser<JavacValues> parser = Parser<JavacValues> {
		createValues = JavacValues;
		bindOptions = {classpathOption};
		lastArgsHandler = lastArgsHandler;
	}; 
	
	JavacValues|Error settings = parser.parse([
		"-cp", "some/class/path", 
		"source0.java", "soource1.java", "source2.java"]);
	 
	if(is Error settings) {
		settings.printIndented(process.writeErrorLine);
	} else {
		// print "help:true, target:target, sources:{ source0, soource1, source2 }"
		print("CLI args OK: classPath:``settings.classPath else "<not set>"``, sources:``settings.sources``");
	}
	
}
