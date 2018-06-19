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
	Path
}

class DefaultCacheTest() 
{
	class DummyInput(String initialValue, variable TaskPath taskPath, String valueName) satisfies Input & Output {
		shared variable String val = initialValue;
		
		shared actual CacheId id() => CacheId(concatenate(taskPath.elements, [valueName]));
		
		shared actual JsonObject|Error toJson() => JsonObject{"val"-> val};
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {this.taskPath = newTaskPath;}
		
		shared actual Error? updateCache(JsonObject content) {
			if(exists v = content.getStringOrNull("val")) {
				this.val = v;
				return null;
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
		cache.updateFrom([input0]);
		
		value retrieved = DummyInput("", taskPath, "value0");
		cache.updateTo([retrieved]);
		
		assertEquals(retrieved.val, "Value 0");
	}
	
	test
	shared void storeCacheAsStringAndRetrieve() {
		value cache = DefaultCache{};
		TaskPath taskPath = TaskPath(ProjectPath(["root", "project"]), "someTask");
		
		cache.updateFrom([
			DummyInput("Value 0", taskPath, "value0"), 
			DummyInput("Value 1", taskPath, "value1")
		]);
		String json = assertNotError(cache.toJson());

		// Copy into new cache
		value readCache = DefaultCache{};
		readCache.loadString(json);
		
		value retrieved0 = DummyInput("", taskPath, "value0");
		readCache.updateTo([retrieved0]);
		assertEquals(retrieved0.val, "Value 0");
		
		value retrieved1 = DummyInput("", taskPath, "value1");
		readCache.updateTo([retrieved1]);
		assertEquals(retrieved1.val, "Value 1");
	}

	test
	shared void storeCacheAsFileAndRetrieve() {
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_")) { 
			Path cachePath = projectRootDir.path.childPath("cache.json");
			
			value cache = DefaultCache{};
			TaskPath taskPath = TaskPath(ProjectPath(["root", "project"]), "someTask");
			
			cache.updateFrom([
				DummyInput("Value 0", taskPath, "value0"), 
				DummyInput("Value 1", taskPath, "value1")
			]);
			
			cache.storeFile(cachePath);
			
			// Copy into new cache
			value readCache = DefaultCache{};
			readCache.loadFile(cachePath);
			
			value retrieved0 = DummyInput("", taskPath, "value0");
			readCache.updateTo([retrieved0]);
			assertEquals(retrieved0.val, "Value 0");
			
			value retrieved1 = DummyInput("", taskPath, "value1");
			readCache.updateTo([retrieved1]);
			assertEquals(retrieved1.val, "Value 1");
		}
	}
	
	
}