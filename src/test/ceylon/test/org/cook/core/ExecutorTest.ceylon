import ceylon.test {
	test,
	assertEquals
}

import org.cook.core {
	Executor,
	Project,
	Task,
	TaskResult,
	Success,
	categories
}
import org.cook.core.filesystem {
	AbsolutePath
}
class ExecutorTest() 
{
	test
	shared void dumpAllTasks() {
		StringBuilder sb = StringBuilder();
		
		Project project = Project("root");
		
		project.addTask(object extends Task("task0", null) {
			category = categories.build;
			description = "Description of Task 0";
			shared actual TaskResult execute(AbsolutePath projectRootPath) => Success("");
		});
		project.addTask(object extends Task("task1", null) {
			category = categories.build;
			description = "Description of Task 1";
			shared actual TaskResult execute(AbsolutePath projectRootPath) => Success("");
		});
		
		Executor().dumpAllTasks(project, sb.append);
		
		String shellText = sb.string;
		void assertContains(String subString) {
			if(shellText.contains(subString)) {
				return;
			}
			throw AssertionError("Substring '``subString``' expected in '``shellText``'.");
		}
		
		assertContains(categories.build.name);
		assertContains("task0");
		assertContains("Description of Task 0");
		assertContains("task1");
		assertContains("Description of Task 1");
		
		
	}
	
	test
	shared void runAfter() {
		Project project = Project("");
		
		class DummyTask (String name, Project project) extends Task(name, project) {
			shared actual TaskResult execute(AbsolutePath projectRootPath) => Success("");
		}
		
		value mainTask= DummyTask("main", project);
		value depTask= DummyTask("dep", project);
		value auxTask= DummyTask("aux", project);
		
		mainTask.addDependency(depTask, {});
		mainTask.runAfter(auxTask);
		auxTask.runAfter(depTask);
		
		// Whatever the initial order of the 3 tasks, they're sorted in the same way
		for(initTasks in [mainTask, auxTask, depTask].permutations ) {
			assertEquals(Executor().sortTaskGraph(initTasks), [depTask, auxTask, mainTask]);
		}
		
		// If the auxTask is not in input, it's not in output (runAfter != dependency)
		for(initTasks in [mainTask, depTask].permutations ) {
			assertEquals(Executor().sortTaskGraph(initTasks), [depTask, mainTask]);
		}
	}
	
}