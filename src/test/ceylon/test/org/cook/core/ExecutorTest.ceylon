import ceylon.test {
	test
}

import org.cook.core {
	Executor,
	Project,
	Task,
	Error,
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
		
		project.addTask(object extends Task("task0") {
			category = categories.build;
			description = "Description of Task 0";
			shared actual Error|TaskResult execute(AbsolutePath projectRootPath) => Success("");
		});
		project.addTask(object extends Task("task1") {
			category = categories.build;
			description = "Description of Task 1";
			shared actual Error|TaskResult execute(AbsolutePath projectRootPath) => Success("");
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
	
}