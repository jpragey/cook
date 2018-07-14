import ceylon.file {
	temporaryDirectory,
	File,
	Nil
}
import ceylon.test {
	test,
	tag,
	assertEquals
}

import org.cook.core.filesystem {
	RelativePath,
	AbsolutePath,
	current
}
import org.cook.plugins.standard {
	JarTask,
	JarExtractTask
}

import test.org.cook.core {
	TestDirEntry,
	TestFileEntry,
	assertNotError
}
import org.cook.core {
	Success,
	DefaultCache,
	FromCache
}

class JarTaskTest() 
{
	test
	tag("integration")
	shared void basicjarTest() {
		
		/* <root>
		 * +-- source/
		 *     +-- {f0.txt, f1.txt}
		 *     +-- sub0/sub1/{f2.txt, f3.txt}
		 * +-- all.jar
		 * +-- target/
		 
		 */
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"), 
			sourceDir = TestDirEntry(projectRootDir, "source"),
			sourceF0  = TestFileEntry(sourceDir, "f0.txt", "f0"),
			sourceF1  = TestFileEntry(sourceDir, "f1.txt", "f1"),
			sourceSub0Dir     = TestDirEntry(sourceDir,     "sub0"),
			sourceSub0Sub1Dir = TestDirEntry(sourceSub0Dir, "sub1"),
			sourceSub0Sub1F2 = TestFileEntry(sourceSub0Sub1Dir, "f2.txt", "f2"),
			sourceSub0Sub1F3 = TestFileEntry(sourceSub0Sub1Dir, "f3.txt", "f3"),
			
			targetDir = TestDirEntry(projectRootDir, "target")
		)
		{
			RelativePath jarPath = RelativePath("all.jar");
			JarTask task = JarTask(jarPath);
			
			task.addPath(RelativePath("source"), RelativePath(current));
			
			value rootDirPath = AbsolutePath(projectRootDir.path);
			assertNotError(task.execute(rootDirPath));
			
			assert(is File jar = rootDirPath.append(jarPath).path.resource);
			
			// -- Extract
			JarExtractTask extractTask = JarExtractTask {
				jarFile = AbsolutePath(projectRootDir.path).append(jarPath);
			};
			
			assertNotError(extractTask.execute(rootDirPath.append(RelativePath("target"))));
			
			assert(is File extractedF2 = targetDir.absolutePath("sub0", "sub1", "f2.txt").path.resource);
			assert(is File extractedManifest = targetDir.absolutePath("META-INF/MANIFEST.MF").path.resource);
			
		}
	}
	
	test
	tag("integration")
	shared void cacheTest() {
		DefaultCache cache = DefaultCache{}; 

		/* <root>
		 * +-- source/
		 *     +-- {f0.txt, f1.txt}
		 *     +-- sub0/sub1/{f2.txt, f3.txt}
		 * +-- all.jar
		 * +-- target/
		 */
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"), 
			sourceDir = TestDirEntry(projectRootDir, "source"),
			sourceF0  = TestFileEntry(sourceDir, "f0.txt", "f0"),
			sourceF1  = TestFileEntry(sourceDir, "f1.txt", "f1"),
			sourceSub0Dir     = TestDirEntry(sourceDir,     "sub0"),
			sourceSub0Sub1Dir = TestDirEntry(sourceSub0Dir, "sub1"),
			sourceSub0Sub1F2 = TestFileEntry(sourceSub0Sub1Dir, "f2.txt", "f2"),
			sourceSub0Sub1F3 = TestFileEntry(sourceSub0Sub1Dir, "f3.txt", "f3"),
			
			targetDir = TestDirEntry(projectRootDir, "target"),
			unpackDir0 = TestDirEntry(projectRootDir, "unpack0"),
			unpackDir1 = TestDirEntry(projectRootDir, "unpack1"),
			unpackDir2 = TestDirEntry(projectRootDir, "unpack2"),
			unpackDir3 = TestDirEntry(projectRootDir, "unpack3")
		)
		{
			RelativePath jarPath = RelativePath("all.jar");
			JarTask task = JarTask {
				jarRPath = jarPath;
				cache_ = cache;
			};
			
			task.addPath(RelativePath("source"), RelativePath("f0.txt"));
			task.addPath(RelativePath("source"), RelativePath("f1.txt"));
			
			value rootDirPath = AbsolutePath(projectRootDir.path);
			assertNotError(task.checkAndExecute(rootDirPath));
			assert(assertNotError(task.lastResult) is Success< Anything>);	// First time empty 
			
			AbsolutePath jarAbsPath = rootDirPath.append(jarPath);
			assert(is File jar = jarAbsPath.path.resource);
			
			// -- Extract
			void checkJar(AbsolutePath unpackDirPath) {
				JarExtractTask extractTask = JarExtractTask {
					jarFile = AbsolutePath(projectRootDir.path).append(jarPath);
				};
				
				assertNotError(extractTask.execute(unpackDirPath));
				
				assert(unpackDirPath.add("f0.txt").path.resource is File);
				assert(unpackDirPath.add("META-INF/MANIFEST.MF").path.resource is File);
			}
			
			checkJar(unpackDir0.absolutePath());
			
			// -- Run another one, same inputs/output -> cache match & no change
			JarTask cacheMatchingTask = JarTask {
				jarRPath = jarPath;
				cache_ = cache;
			};
			cacheMatchingTask.addPath(RelativePath("source"), RelativePath("f0.txt"));
			cacheMatchingTask.addPath(RelativePath("source"), RelativePath("f1.txt"));
			
			assertEquals(cacheMatchingTask.checkAndExecute(rootDirPath), FromCache {updated = false;});
			assertEquals(cacheMatchingTask.lastResult, FromCache {updated = false;}); 
			checkJar(unpackDir1.absolutePath());
			
			// -- Run another one, output changed (jar deleted) -> cache mismatch & change
			assert(is File jarFile = jarAbsPath.path.resource);
			jarFile.delete();
			assert(jarAbsPath.path.resource is Nil);
			
			JarTask outputChangedTask = JarTask {
				jarRPath = jarPath;
				cache_ = cache;
			};
			outputChangedTask.addPath(RelativePath("source"), RelativePath("f0.txt"));
			outputChangedTask.addPath(RelativePath("source"), RelativePath("f1.txt"));
			
			assertEquals(outputChangedTask.checkAndExecute(rootDirPath), FromCache {updated = true;});
			assertEquals(outputChangedTask.lastResult, FromCache {updated = true;}); 
			checkJar(unpackDir2.absolutePath());
			
			// -- Run another one, input changed (f1.txt changed) => Success
			assert(is File f1File = sourceF1.path.resource);
			//f1File.delete();
			try(writer = f1File.Overwriter()) {
				writer.write("updated");
			}
			
			JarTask inputChangedTask = JarTask {
				jarRPath = jarPath;
				cache_ = cache;
			};
			inputChangedTask.addPath(RelativePath("source"), RelativePath("f0.txt"));
			inputChangedTask.addPath(RelativePath("source"), RelativePath("f1.txt"));
			
			value execStatus = assertNotError(inputChangedTask.checkAndExecute(rootDirPath));
			assert(execStatus is Success<Anything>);
			assert(inputChangedTask.lastResult  is Success<Anything>); 
			checkJar(unpackDir3.absolutePath());
		}
	}	
	
	
}