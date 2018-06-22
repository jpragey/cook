import ceylon.collection {
	MutableList,
	ArrayList
}
import org.cook.core.filesystem {
	AbsolutePath
}





shared class Project(shared String name, shared String dirName = name) {
	
	shared variable Project? parent = null;
	shared ProjectPath projectPath => 
			if(exists p = parent) 
			then p.projectPath.child(name, dirName)
			else ProjectPath([name]);
	
	shared actual String string => projectPath.string;
	
	MutableList<Project> internalChildren = ArrayList<Project>();
	shared List<Project> children => internalChildren;
	
	MutableList<Task> internalTasks = ArrayList<Task>();
	shared default {Task *} tasks => internalTasks;
	
	shared Error? checkSanity() {
		ArrayList<Error> errors = ArrayList<Error>();
		
		// Check children
		for(Project child in children) {
			if(exists parent = child.parent) {
				if(parent != this) {
					errors.add(Error("Internal error: project ``child.projectPath`` has a parent (project) attribute referring to ``parent.projectPath``; it should refer to ``this.projectPath`` ."));
				}
			} else {
				errors.add(Error("Internal error: project ``child.projectPath`` has a null parent (project) attribute; it should refer to ``this.projectPath`` ."));
			}
		}
		
		// Recurse on children
		errors.addAll(children*.checkSanity().coalesced);
		
		// Check tasks
		for(task in tasks) {
			if(exists parent = task.project) {
				if(parent != this) {
					errors.add(Error("Internal error: task ``task.taskPath()`` has a project attribute referring to ``parent.projectPath``; it should refer to ``this.projectPath`` ."));
				}
			} else {
				errors.add(Error("Internal error: task ``task.taskPath()`` has a null parent (project) attribute; it should refer to ``this.projectPath`` ."));
			}
		}

		if(nonempty e = errors.sequence()) {
			return Error("Internal error: project/task tree not coherent under ``projectPath``.", e);
		}
		
		return null;
	}
	
	shared void updateParent(Project? newParent) {
		this.parent = newParent;
		//this.projectPath = (this.parent?.projectPath else ProjectPath.root) .child(name);
		
		children*.updateParent(this);
		tasks*.updateParent(this);
	}
	
	shared Error|[Anything *] executeTasks(AbsolutePath projectRootPath) {
		variable [Anything *] results = [];
		for(task in tasks) {
			switch(res = task.execute(projectRootPath))
			case(is Failed) {return res.cause;}	
			else {
				results = results.append([res]);
			}
		}
		return results;
	}
	
	shared void visitProjects(ProjectVisitor visitor) {
		visitor.before(this);
		children*.visitProjects(visitor);
		visitor.after(this);
	}
	shared void visitTasks(TaskVisitor visitor, Boolean deep) {
		
		visitor.beforeProject(this);
		
		if(deep) {
			children*.visitTasks(visitor, deep);
		}
		
		for(task in tasks) {
			visitor.before(this, task);
			visitor.after(this, task);
		}
		visitor.afterProject(this);
	}
	
	shared void addChildrenProjects(Project* children) {
		for(child in children) {
			child.updateParent(this);
			internalChildren.add(child);
		}
	}
	
	shared ChildTask addTask<ChildTask>(ChildTask child) given ChildTask satisfies Task {
		child.updateParent(this);
		internalTasks.add(child);
		return child;
	}
	shared void addAllTask(Task* children) {
		children.each(addTask);
	}
	
	shared default Project[] findProjects(Boolean(Project) matcher) {
		ArrayList<Project> result = ArrayList<Project>();
		visitProjects(object satisfies ProjectVisitor {
			shared actual void before(Project project) {
				if(matcher(project)) {
					result.add(project);
				}
			}
		});
		return result.sequence();
	}
	
	shared default Task[] findTasks(
		Boolean(Task) matcher) 
	{
		ArrayList<Task> result = ArrayList<Task>();
		
		visitTasks {
			visitor = object satisfies TaskVisitor {
				
				shared actual void before(Project project, Task task) {
					if(matcher(task)) {
						result.add(task);
					}
				}
			};
			deep = true;
		};
		return result.sequence();
	}
	
}

