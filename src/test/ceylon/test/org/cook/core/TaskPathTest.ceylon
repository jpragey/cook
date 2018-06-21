import ceylon.test {
	test,
	assertEquals
}
import org.cook.core {
	TaskPath,
	ProjectPath
}
import org.cook.core.filesystem {
	RelativePath
}
class TaskPathTest() 
{
	test
	shared void basePath() {
		
		assertEquals(
			TaskPath(ProjectPath(["root", "child0", "child1"], ["child0Dir", "child1Dir"]), "aTask").basePath,
			RelativePath("child0Dir", "child1Dir") 
		);
		 
		assertEquals(
			TaskPath(ProjectPath(["root", "child0", "child1"]), "aTask").basePath,
			RelativePath("child0", "child1") 
		); 
	}
}