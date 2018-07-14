import ceylon.test {
	test,
	assertEquals
}
import org.cook.core {
	DefaultCache,
	Input,
	CacheId,
	Error,
	TaskPath,
	ProjectPath,
	Output
}
import ceylon.json {
	JsonObject
}
import ceylon.file {
	temporaryDirectory,
	Path,
	current
}
import org.cook.core.filesystem {
	AbsolutePath
}

class DefaultCacheTest() 
{
	class DummyInput(String initialValue, variable TaskPath taskPath, String valueName) satisfies Input & Output {
		shared variable String val = initialValue;
		
		shared actual CacheId id() => CacheId(concatenate(taskPath.elements, [valueName]));
		
		shared actual JsonObject|Error toJson(AbsolutePath root) => JsonObject{"val"-> val};
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {this.taskPath = newTaskPath;}
		
		shared actual Error|Boolean updateFrom(JsonObject content, AbsolutePath root) {
			if(exists v = content.getStringOrNull("val")) {
				if(this.val == v) {
					return false;
				} else {
					this.val = v;
					return true;
					
				}
			} else {
				return Error("No 'val' string found in json object ``taskPath``:``valueName`` : JSON object = ``content``");
			}
		}
		
	}
	
	test
	shared void storeAndRetrieve() {
		value cache = DefaultCache{};
		TaskPath taskPath = TaskPath(ProjectPath(["root", "project"]), "someTask");
		
		value input0 = DummyInput("Value 0", taskPath, "value0");
		cache.updateFrom(input0, AbsolutePath(current)/*TODO: ???*/);
		
		value retrieved = DummyInput("", taskPath, "value0");
		cache.updateTo(retrieved, AbsolutePath.current /*TODO: ???*/ );
		
		assertEquals(retrieved.val, "Value 0");
	}
	
	test
	shared void storeCacheAsStringAndRetrieve() {
		value cache = DefaultCache{};
		TaskPath taskPath = TaskPath(ProjectPath(["root", "project"]), "someTask");
		
		cache.updateFrom(
			DummyInput("Value 0", taskPath, "value0")
			// TODO , 
			//DummyInput("Value 1", taskPath, "value1")
			, AbsolutePath(current)/*TODO: ???*/
		);
		String json = assertNotError(cache.toJson());

		// Copy into new cache
		value readCache = DefaultCache{};
		readCache.loadString(json);
		
		value retrieved0 = DummyInput("", taskPath, "value0");
		readCache.updateTo(retrieved0, AbsolutePath.current /*TODO: ???*/ );
		assertEquals(retrieved0.val, "Value 0");
	}

	test
	shared void storeCacheAsFileAndRetrieve() {
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_")) { 
			Path cachePath = projectRootDir.path.childPath("cache.json");
			
			value cache = DefaultCache{};
			TaskPath taskPath = TaskPath(ProjectPath(["root", "project"]), "someTask");
			
			cache.updateFrom(
				DummyInput("Value 0", taskPath, "value0")
				// TODO , 
				//DummyInput("Value 1", taskPath, "value1")
				, AbsolutePath(projectRootDir.path)
			);
			
			cache.storeFile(cachePath);
			
			// Copy into new cache
			value readCache = DefaultCache{};
			readCache.loadFile(cachePath);
			
			value retrieved0 = DummyInput("", taskPath, "value0");
			readCache.updateTo(retrieved0, AbsolutePath.current /*TODO: ???*/ );
			assertEquals(retrieved0.val, "Value 0");
		}
	}
	
	
}