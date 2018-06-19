shared interface TaskVisitor {
	shared default void before(Project project, Task task) {}
	shared default void after (Project project, Task task) {}
	
	shared default void beforeProject(Project project) {}
	shared default void afterProject(Project project) {}
}