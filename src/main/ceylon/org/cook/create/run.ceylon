

object exitCodes {
	shared Integer ok = 0;
	shared Integer failed = 1;
}

""
suppressWarnings("expressionTypeNothing")
//shared void run0() {
//	Integer exitCode = ProjectWithLibsBuilder().buildHelloWorld();
//	process.exit(exitCode);
//}

shared void run() {
	
	String? askOption(String explain, String default) {
		process.write(explain);
		String? answer = process.readLine();
		
		if(exists answer) {
			return if(answer.empty) then default else answer;
		} else {
			return null;
		}
	}
	
	variable String projectName = "org.demo.helloWorld";
	if(exists answer = askOption("Enter project name [``projectName``]:", projectName)) {
		projectName = answer;
	} else {
		process.exit(exitCodes.failed);
	}

	Integer exitCode = ProjectWithLibsBuilder().buildHelloWorld(projectName);
	process.exit(exitCode);
	
}




