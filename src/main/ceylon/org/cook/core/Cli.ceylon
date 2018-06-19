import ceylon.collection {
	LinkedList
}

import org.cook.cli {
	BindableWithHelp,
	Cursor,
	BooleanOption,
	CliError=Error,
	Parser
}

shared interface Cli 
{
	shared formal Boolean help;
	shared formal Boolean describe;
	shared formal Boolean version;
	
	shared formal [String *] extraArgs;
	
}

"'help' option values. All terms following on CLI are topics."
class HelpCommandValues() {
	""
	shared variable List<String> topics = LinkedList<String>();
	
	//shared Error? addTopics({String *} topics) {this.topics.addAll(topics); return null;}
	"Set add all cursor arguments to [[HelpCommandValues.topics]].
	 Note that its signature [Error? (Cursor)] makes it a valid candidate for a last arguments handler."
	shared Error? addTopics(Cursor topics) {this.topics = topics.args; return null;}
}

class CliImpl() satisfies Cli {
	
	shared variable actual Boolean help = false;
	shared CliError? doSetHelp() {help = true; return null;}
	
	
	shared variable actual Boolean describe = false;
	shared CliError? doSetDescribe() {describe = true; return null;}
	
	shared variable actual Boolean version = false;
	shared CliError? doSetVersion() {version = true; return null;}
	
	shared variable actual [String *] extraArgs = [];
	shared CliError? appendExtra([String +] extraArgs) {this.extraArgs = extraArgs; return null;}
}

shared class HelpTopic(shared String shortHelp){}

"
 Return null to exit immediately (eg after --help)
 "
shared Cli|Error? parseCli(
	String[] cliArgs = process.arguments, 
	Anything (String ) writeHelp = print, 
	Anything (String ) writeVersion = print
) {
	
	BindableWithHelp<CliImpl, HelpTopic> helpOption = BooleanOption<CliImpl> {
		names = ["-h", "--help"];
		setter = CliImpl.doSetHelp;
	}.withHelp(HelpTopic(
		"-h, --help   Print help and exit."));
	
	BindableWithHelp<CliImpl, HelpTopic> describeOption = BooleanOption<CliImpl> {
		names = ["-d", "--describe"];
		setter = CliImpl.doSetDescribe;
	}.withHelp(HelpTopic(
		"-d, --describe  Describe project/tasks graph."));
	
	BindableWithHelp<CliImpl, HelpTopic> versionOption = BooleanOption<CliImpl> {
		names = ["-v", "--version"];
		setter = CliImpl.doSetVersion;
	}.withHelp(HelpTopic(
		"-v, --version  Print version and exit."));
	
	
	"Last arguments handler (manages source files here)"
	CliError? lastArgsHandler(CliImpl appValues)(Cursor cursor) 
			=> appValues.appendExtra(cursor.args);
	
	value allOptions = {helpOption, describeOption, versionOption}; 
	
	CliImpl cliImpl = CliImpl();
	
	// Note: added HelpData parameter
	Parser<CliImpl> parser = Parser<CliImpl> {
		createValues = cliImpl;
		bindOptions = allOptions /*{classpathOption, helpOption}*/;
		lastArgsHandler = lastArgsHandler;
	}; 
	
	switch(Cli|CliError javacValues = parser.parse(cliArgs))
	case (is Cli) {
		if(javacValues.help) {
			printHelp(allOptions*.help, writeHelp);
			return null;
		}
		if(javacValues.version) {
			return printVersion(writeVersion);
		}
		
		//print("Application config: ``appConfig``");
		return javacValues;
	}
	case (is CliError) {
		return Error.fromCli(javacValues);
	}
}

"Print error"
Error? printVersion(Anything (String) write) {
	String resourcePath = "version.json";
	if(exists resource = `module`.resourceByPath(resourcePath)) {
		String version = resource.textContent("UTF8");
		write(version);
		return null;
	} else {
		return Error("Resource path ``resourcePath`` not found.");
		//write("Resource path ``resourcePath`` not found.");
	}
}

void printHelp({HelpTopic *} helpDatas, Anything (String ) write) {
	write("""cook - build system.
	           ceylon run -- <build task name> [option]... <task filter>...
	         """);
	
	for(h in helpDatas) {
		write("  ``h.shortHelp``");
	}
}


