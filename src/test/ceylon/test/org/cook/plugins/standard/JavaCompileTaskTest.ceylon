import ceylon.file {
	File,
	temporaryDirectory,
	Nil
}
import ceylon.test {
	test,
	tag,
	assertEquals
}

import org.cook.core {
	Success,
	DefaultCache,
	CacheId,
	FromCache
}
import org.cook.core.filesystem {
	AbsolutePath
}
import org.cook.plugins.standard {
	JavaCompileTask
}

import test.org.cook.core {
	TestDirEntry,
	TestFileEntry
}
class JavaCompileTaskTest() 
{
	test
	tag("integration")
	shared void cacheMatchTest() {
		DefaultCache cache = DefaultCache{}; 
		value task = JavaCompileTask{cache_ = cache;};
		
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"),
			// src
			// +--- main.java
			// target/classes/Main.class
			sourceDir = TestDirEntry(projectRootDir, "src"),
			sourceFile0 = TestFileEntry(sourceDir, "Main.java", 
				"public class Main {
				     public static void main(String[] args) {
				     	System.out.println(\"Hello World\");
				     }
				 }
				 "),
			targetDir = TestDirEntry(projectRootDir, "target")
		)
		{
			
			
			assert(is Null resultBeforeExec = task.lastResult);
			value root = AbsolutePath(projectRootDir.path);
			assert(is Success<Anything> execResult = task.checkAndExecute(root));
			
			assert(is Success<Anything> lastResult = task.lastResult);

			AbsolutePath mainClassPath = targetDir.absolutePath("classes", "Main.class");
			assert(is File createdMainClassFile = mainClassPath.resource );
			Byte[] initialMainClassBytes;
			try(reader = createdMainClassFile.Reader()) {
				initialMainClassBytes = reader.readBytes(createdMainClassFile.size);
			}
			
			
			//print( assertNotError(task.input.toJson(root)).pretty);
			
			CacheId inputCacheId = CacheId(task.taskPath().elements.append(["in"]));
			CacheId outputCacheId = CacheId(task.taskPath().elements.append(["out"]));
			
			assert(exists inputJs = cache.get(inputCacheId));
			//print("Cache for id=``inputCacheId`` : ``inputJs.pretty``");
			
			assert(exists outputJs = cache.get(outputCacheId));
			//print("Cache for id=``outputCacheId`` : ``outputJs.pretty``");
			
			//print("Cache ids=``cache.ids``");
			
			// -- run another JavaCompileTask (with matching cache now)
			value secondTask = JavaCompileTask{cache_ = cache;};
			assertEquals(secondTask.lastResult, null);
			assertEquals(secondTask.checkAndExecute(root), FromCache(false));
			assertEquals(secondTask.lastResult, FromCache {updated = false;});
			
			// -- Remove Main.class, run again and check it is recreated
			createdMainClassFile.delete();
			assert(mainClassPath.resource is Nil);
			
			value thirdTask = JavaCompileTask{cache_ = cache;};
			assertEquals(thirdTask.lastResult, null);
			assertEquals(thirdTask.checkAndExecute(root), FromCache {updated = true;});
			assertEquals(thirdTask.lastResult, FromCache {updated = true;});
			
			assert(is File recreatedFile = mainClassPath.resource );
			try(reader = recreatedFile.Reader()) {
				Byte[] recreatedMainClassBytes = reader.readBytes(recreatedFile.size);
				assertEquals(recreatedMainClassBytes, initialMainClassBytes);
			}
		}

	}

}