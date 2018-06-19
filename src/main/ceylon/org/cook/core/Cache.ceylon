import ceylon.json {
	JsonObject
}

shared class CacheId(shared String[] path) {
	shared actual Boolean equals(Object that) {
		if (is CacheId that) {
			return path==that.path;
		}
		else {
			return false;
		}
	}
	shared actual Integer hash => path.hash;
}

shared interface CacheElement {
	shared formal CacheId id(/*ProjectPath projectPath*/);
	shared formal JsonObject|Error toJson();
	shared formal void updateTaskPath(TaskPath newTaskPath);
}

shared interface Input satisfies CacheElement {
}


shared class InputString(String initialValue, variable TaskPath taskPath, String valueName) satisfies Input {
	
	shared variable String val = initialValue; 
	
	shared actual CacheId id() => CacheId(concatenate(taskPath.elements, [valueName]));
	
	shared actual JsonObject|Error toJson() => JsonObject{"value" -> val};
	
	shared actual void updateTaskPath(TaskPath newTaskPath) {
		this.taskPath = taskPath;
	}
	
}


shared interface Output satisfies CacheElement {
	shared formal Error? updateCache(JsonObject content);
}

shared interface Cache 
{
	shared formal Boolean match(CacheElement [] currentCacheElements);
	
	shared formal Error? updateFrom(CacheElement [] currentCacheElements);
	
	shared formal Error? updateTo(Output [] currentCacheElements);
}

