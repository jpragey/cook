
shared interface TaskResult /*of Success<TaskResult> | Failed */{
}

shared class Success<out T>(shared T result) satisfies TaskResult  given T satisfies Object {
	
}

shared class Failed(shared Error cause) satisfies TaskResult {
	
}






