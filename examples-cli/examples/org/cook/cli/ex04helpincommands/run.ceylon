import org.cook.cli {
	Error,
	StringOption,
	CommandOption,
	Parser,
	BooleanOption
}

shared interface WithCwd {
	shared formal variable String? cwd;
	shared default Error? setCwd(String val) {
		this.cwd = val;
		return null;
	}
	//shared default void setCwdNoCheck(String val) => this.cwd = val;
}

shared interface CommandConfig of CompileConfig | DocConfig {
	shared formal Error? execute("Specific commands may need the global options" AppConfig appConfig);
}

shared class CompileConfig() satisfies CommandConfig & WithCwd {
	shared actual variable String? cwd = null;

	shared variable String? javac = null;
	shared default Error? setJavac(String val) {
		this.javac = val;
		return null;
	}
	//shared actual String string => "Compile[cwd=``cwd else "<null>"``, javac=``javac else "<null>"``]";
	shared actual Error? execute(AppConfig appConfig) {
		print("Executing Compile[cwd=``cwd else "<null>"``, javac=``javac else "<null>"``]");
		return null;
	}
}

shared class DocConfig() satisfies CommandConfig & WithCwd {
	shared actual variable String? cwd = null;
	
	shared variable String? doc = null;
	shared default Error? setDoc(String val) {
		this.doc = val;
		return null;
	}
	
	shared actual String string => "Doc[cwd=``cwd else "<null>"``, doc=``doc else "<null>"``]";
	shared actual Error? execute(AppConfig appConfig) {
		print("Executing ``string``");
		return null;
	}
}

shared class AppConfig() {
	shared alias CommandConfig => CompileConfig|DocConfig;
	
	shared variable CommandConfig? commandConfig = null;

	shared CommandConfig setConfig(CommandConfig config) => this.commandConfig = config;
	
	shared CompileConfig setCompileCommand() => this.commandConfig = CompileConfig ();
	shared DocConfig setDocCommand() => this.commandConfig = DocConfig ();
	
	// Non-command options
	shared variable Boolean? version = false;
	shared Null setVersion() { version = true; return null;}

	shared actual String string => "version=``version else "<null>"``, command=``commandConfig else "<null>"``";
	shared Error? execute() {
		if(exists cfg = commandConfig) {
			return cfg.execute(this); 
		}
		print("No command, version=``version else "<null>"``"); 
		return null;
	}
	//	print("Executing ``string``");
	//}
}


"Ceylon-like commands
 
 	ceylon compile  --cwd=<dir> --javac=<option>
 	ceylon doc --cwd=<dir> --doc=<dirs>
 "
shared void run() {
	
	// -- Create non-command options
	//StringOption<WithCwd>       cwdOption =     StringOption<WithCwd>(["--cwd"], WithCwd.setCwd );
	StringOption<WithCwd>       cwdOption =     StringOption<WithCwd>(["--cwd"], WithCwd.setCwd );
	StringOption<CompileConfig> javacOption =   StringOption<CompileConfig>(["--javac"], CompileConfig.setJavac);
	StringOption<DocConfig>     docOption =     StringOption<DocConfig>(["--doc"], DocConfig.setDoc);
	BooleanOption<AppConfig>    versionOption = BooleanOption<AppConfig>(["--version"], AppConfig.setVersion);


	// -- create command options
	value compileOption = CommandOption<AppConfig, CompileConfig> {
		names = "compile";
		function createValues(AppConfig values) => values.setCompileCommand();
		bindOptions = {javacOption, cwdOption};
	};
	value docCmdOption = CommandOption<AppConfig, DocConfig>(
		"doc", 
		(AppConfig values)  => values.setDocCommand(), 
		{
			docOption,
			cwdOption
		}
	);

	Parser<AppConfig> parser = Parser<AppConfig>(AppConfig, {
		compileOption,
		docCmdOption,
		versionOption
	});


	void parseAndExecute(String[] args) {
		switch(AppConfig|Error appConfig = parser.parse(args))
		case (is AppConfig) {
			appConfig.execute();
			//print("Application config: ``appConfig``");
		}
		case (is Error) {
			appConfig.printIndented(process.writeErrorLine);
		}
	}

	parseAndExecute(["compile", "--cwd", "/home/jdoe/tests", "--javac", "-deprecation"]);
	parseAndExecute(["doc", "--cwd", "/home/jdoe/tests", "--doc", "/home/jdoe/tests/doc"]);
	parseAndExecute(["--version"]);
    
}
