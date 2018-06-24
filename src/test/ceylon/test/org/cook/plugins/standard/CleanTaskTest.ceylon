import ceylon.test {
	test
}
import test.org.cook.core {
	TestDirEntry,
	TestFileEntry
}
import ceylon.file {
	temporaryDirectory,
	Directory,
	Nil
}
import org.cook.core {
	Project
}
import org.cook.plugins.standard {
	CleanTask
}
import org.cook.core.filesystem {
	RelativePath,
	AbsolutePath
}
class CleanTaskTest() 
{
	test
	shared void cleanTest() {
		
		// <temp>
		// +-- project/
		//     +-- classes/package/{a.class, b.class}
		//     +-- project.jar
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"), 
			projectDir = TestDirEntry(projectRootDir, "project"),
			projectClassesDir = TestDirEntry(projectDir, "classes"),
			projectClassesPackDir = TestDirEntry(projectClassesDir, "package"),
			projectClassesPackDirA = TestFileEntry(projectClassesPackDir, "A.class", {10,11,12}*.byte),
			projectClassesPackDirB = TestFileEntry(projectClassesPackDir, "B.class", {20,21,22}*.byte),

			projectJar = TestFileEntry(projectDir, "project.jar", {40,41,42}*.byte)
		)
		{
			Project project = Project("root");
			value task = CleanTask("clean", [
				RelativePath("project", "classes"),
				RelativePath("project", "project.jar")
			], project);
			
			task.execute(AbsolutePath(projectRootDir.path));
			
			assert(is Directory d = projectDir.path.resource);
			assert(is Nil removedClasses = projectClassesDir.path.resource);
			assert(is Nil removedJar = projectJar.path.resource);
		}
	}
}
