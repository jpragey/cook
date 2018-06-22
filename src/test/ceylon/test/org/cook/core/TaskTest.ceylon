import ceylon.test {
	test,
	assertEquals
}
import org.cook.core {
	Project,
	Task,
	TaskResult,
	Error,
	Input,
	Output,
	TaskPath,
	ProjectPath
}
import org.cook.core.filesystem {
	AbsolutePath
}
class TaskTest() 
{
	class DoNothingTask(String name) extends Task(name, null) {
		
		shared actual Error|TaskResult execute(AbsolutePath projectRootPath) => Error("DoNothingTask should not be executed.");
		
		shared actual {Input*} inputCacheElements => [];
		
		shared actual {Output*} outputCacheElements => [];
	}
	
	test
	shared void taskName() {
		Project root = Project("root");
		Project child = Project("child");
		Task task = DoNothingTask("aTask");
		
		assertEquals(task.taskPath(), TaskPath(ProjectPath.undefined, "aTask"));
		
		child.addAllTask(task);
		assertEquals(task.taskPath().dirElements, [ "aTask"]);

		root.addChildrenProjects(child);
		assertEquals(task.taskPath(), TaskPath(ProjectPath(["root", "child"], ["child"]), "aTask"));
	}
}