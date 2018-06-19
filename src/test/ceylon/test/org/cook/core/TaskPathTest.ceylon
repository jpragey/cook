import ceylon.test {
	test,
	assertEquals
}
import org.cook.core {
	TaskPath,
	ProjectPath
}
class TaskPathTest() 
{
	test
	shared void stringContainsSemi() {
		assertEquals(
			TaskPath(ProjectPath(["root", "child"], ["rootDir", "childDir"]), "aTask").string, 
			":root:child:aTask"
		); 
	}
}