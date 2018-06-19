import ceylon.test {
	test,
	assertTrue,
	assertEquals
}

import org.cook.core {
	StdConsole,
	TaskFilter,
	TaskPath,
	ProjectPath
}
class TaskFilterTest() 
{
	Boolean filter(String filterString, TaskPath taskPath) {
		value tf = TaskFilter(filterString);
		return tf.filter(taskPath);
	}
	
	test
	shared void fullPath() {
		assertEquals(filter("project:subproject:task", TaskPath(ProjectPath(["project", "subproject"]),"task")), true);
		assertEquals(filter("*:task",                  TaskPath(ProjectPath(["project", "subproject"]),"task")), true);
		assertEquals(filter("project:subproject:*",    TaskPath(ProjectPath(["project", "subproject"]),"task")), true);
		assertEquals(filter("*:*",                     TaskPath(ProjectPath(["project", "subproject"]),"task")), true);
		assertEquals(filter("task",                    TaskPath(ProjectPath(["project", "subproject"]),"task")), true);
		assertEquals(filter("*",                       TaskPath(ProjectPath(["project", "subproject"]),"task")), true);
		
		assertEquals(filter("project:subproject:task", TaskPath(ProjectPath(["project", "subproject"]),"-task")), false);
		assertEquals(filter("project:subproject:task", TaskPath(ProjectPath(["project", "subproject-"]),"task")), false);
		assertEquals(filter("project:subproject:task", TaskPath(ProjectPath(["project-", "subproject"]),"task")), false);

		assertEquals(filter("*:task",                  TaskPath(ProjectPath(["project", "subproject"]),"task-")), false);
		assertEquals(filter("project:subproject:*",    TaskPath(ProjectPath(["project", "subproject-"]),"task")), false);
		assertEquals(filter("project:subproject:*",    TaskPath(ProjectPath(["project-", "subproject"]),"task")), false);

		assertEquals(filter("task",                    TaskPath(ProjectPath(["project", "subproject"]),"task-")), false);
		
	}
}