
shared interface TaskResult of Success<Object> | Failed {
	shared formal Boolean canContinue;
}

shared class Success<out T>(shared T result) satisfies TaskResult  given T satisfies Object {
	
	shared actual Boolean canContinue => true;
	
}

shared class Failed(shared Error cause) satisfies TaskResult {
	shared actual Boolean canContinue => false;
	
}






