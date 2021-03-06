import ceylon.test {
	test,
	assertEquals
}

import org.cook.core {
	Project,
	Task,
	TaskResult,
	Error,
	TaskPath,
	ProjectPath,
	Failed
}
import org.cook.core.filesystem {
	AbsolutePath
}
class TaskTest() 
{
	class DoNothingTask(String name) extends Task(name, null) {
		
		shared actual TaskResult execute(AbsolutePath projectRootPath) => Failed(Error("DoNothingTask should not be executed."));
		
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
	
	test
	shared void dependencyTest() {
		Task task0 = DoNothingTask("task0");
		Task task1 = DoNothingTask("task1");
		
		task0.addDependency(task1, {});
		
	}
}