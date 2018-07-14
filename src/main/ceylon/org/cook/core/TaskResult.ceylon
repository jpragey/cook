
shared interface TaskResult of Success<Object> | Failed | FromCache {
	shared formal Boolean canContinue;
}

shared class Success<out T>(shared T result) satisfies TaskResult  given T satisfies Object {
	
	shared actual Boolean canContinue => true;
	
}

shared class FromCache(shared Boolean updated) satisfies TaskResult {	// TODO: 
	
	shared actual Boolean canContinue => true;
	shared actual Boolean equals(Object that) {
		if (is FromCache that) {
			return updated==that.updated;
		}
		else {
			return false;
		}
	}
	
}
//shared object fromCache satisfies TaskResult {	// TODO: 
//	
//	shared actual Boolean canContinue => true;
//	
//}

shared class Failed(shared Error cause) satisfies TaskResult {
	shared actual Boolean canContinue => false;
	
}






