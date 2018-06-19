import ceylon.test {
	test,
	assertEquals
}
import org.cook.core {
	Project,
	ProjectVisitor,
	ProjectPath
}
import ceylon.collection {
	ArrayList
}
class ProjectTest() 
{
	Project root = Project("root");
	Project child0 = Project("child0");
	Project child1 = Project("child1");
	root.addChildrenProjects(child0, child1);
	
	test
	shared void buildProjectTree() {
		
		assertEquals(child0.parent, root);
		assertEquals(child1.parent, root);
		
		assertEquals(root.children, [child0, child1]);
	}
	
	test
	shared void testProjectVisitor() {
		
		value actual = ArrayList<String>();
		root.visitProjects(object satisfies ProjectVisitor{
			shared actual void before(Project project) => actual.add("before " + project.name);
			shared actual void after(Project project) =>  actual.add("after " + project.name);
		});
		
		assertEquals(actual.sequence(), [
			"before root",
				"before child0",
				"after child0",
				"before child1",
				"after child1",
			"after root"
		]);
		
	}
	
	test
	shared void testProjectPath() {
		Project root = Project("root", "rootDir");
		Project child0 = Project("child0", "child0Dir");
		Project child1 = Project("child1", "child1Dir");
		root.addChildrenProjects(child0, child1);
		
		assertEquals(root.projectPath, ProjectPath(["root"], ["rootDir"]));
		assertEquals(child0.projectPath, ProjectPath(["root", "child0"], ["rootDir", "child0Dir"]));
		assertEquals(child1.projectPath, ProjectPath(["root", "child1"], ["rootDir", "child1Dir"]));
	}
	
	test
	shared void findProjects() {
		
		assertEquals(root.findProjects((Project project) => project.name=="root"),   [root]);
		assertEquals(root.findProjects((Project project) => project.name=="child0"), [child0]);
		assertEquals(root.findProjects((Project project) => project.name=="child1"), [child1]);
		assertEquals(root.findProjects((Project project) => false), []);
	}
	
}
