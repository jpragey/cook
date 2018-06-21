import ceylon.test {
	test,
	assertEquals
}
import org.cook.core {
	ProjectPath
}
class ProjectPathTest() 
{
	test
	shared void simpleProjectPath() {
		
		assertEquals(ProjectPath(["aaa", "bbb", "ccc"]).projectNames, ["aaa", "bbb", "ccc"]);
		assertEquals(ProjectPath(["aaa", "bbb", "ccc"]).projectDirNames, ["bbb", "ccc"]);
	}
	
	test
	shared void undefinedTest() {
		
		assertEquals(ProjectPath.undefined.projectNames, ["undefined"]);
		assertEquals(ProjectPath.undefined.projectDirNames, []);
	}
}