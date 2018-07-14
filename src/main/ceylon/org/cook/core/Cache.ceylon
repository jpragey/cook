import ceylon.json {
	JsonObject
}
import org.cook.core.filesystem {
	AbsolutePath
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
	shared actual String string => path.string;
}

shared interface CacheElement {
	shared formal CacheId id(/*ProjectPath projectPath*/);
	shared formal JsonObject|Error toJson(AbsolutePath root);
	shared formal void updateTaskPath(TaskPath newTaskPath);
}

shared interface Input satisfies CacheElement {
}


shared class InputString(String initialValue, variable TaskPath taskPath, String valueName) satisfies Input {
	
	shared variable String val = initialValue; 
	
	shared actual CacheId id() => CacheId(concatenate(taskPath.elements, [valueName]));
	
	shared actual JsonObject|Error toJson(AbsolutePath root) => JsonObject{"value" -> val};
	
	shared actual void updateTaskPath(TaskPath newTaskPath) {
		this.taskPath = taskPath;
	}
	
}


shared interface Output satisfies CacheElement {
	"Update output from cached file content. Implementations must check if it caused a change.
	 Return:
	 - true if output changed (eg output file added, removed or changed) 
	 - false if output did not change at all;
	 - Error if something nasty happened. 
	 "
	shared formal Error|Boolean updateFrom(JsonObject content, AbsolutePath root);
}

shared interface Cache 
{
	shared formal Boolean match(CacheElement /*[]*/ currentCacheElements, AbsolutePath root);
	
	"Update cache content from Cache elements (eg files)"
	shared formal Error? updateFrom(CacheElement /*[]*/ currentCacheElements, AbsolutePath root);
	
	shared formal Error|Boolean updateTo(Output /*[]*/ currentCacheElements, AbsolutePath root);
}

