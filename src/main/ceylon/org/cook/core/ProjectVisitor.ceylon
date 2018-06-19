shared interface ProjectVisitor {
	shared default void before(Project project) {}
	shared default void after(Project project) {}
}