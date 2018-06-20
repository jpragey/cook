import org.cook.core.filesystem {
	AbsolutePath
}
import ceylon.collection {
	MutableList,
	ArrayList,
	HashMap
}
import ceylon.language.meta.model {
	Attribute
}
shared interface TaskChecker {
	shared formal Boolean mustExecute();
}



shared class Category(shared String name) {
	shared actual String string => name;
	shared actual Integer hash => name.hash;
	shared actual Boolean equals(Object that) {
		if (is Category that) {
			return name==that.name;
		}
		else {
			return false;
		}
	}
}

shared object categories {
	
	shared HashMap<String, Category> categories = HashMap<String, Category>{};
	void add(Category category) => categories.put(category.name, category);
	
	shared Category build = Category("Build");
	shared Category buildSetup = Category("Build Setup");
	shared Category documentation = Category("Documentation");
	shared Category help = Category("Help");
	shared Category verification = Category("Verification");
	
	{build, buildSetup, documentation, help, verification}.each(add);
	
	shared Category ? byName(String name) => categories.get(name);
}



shared interface AbstractTask {
	
	shared default Error|TaskResult checkAndExecute(AbsolutePath projectRootPath) {
		return execute(projectRootPath);
	}
	
	shared formal Error|TaskResult execute(AbsolutePath projectRootPath);
	
}

shared ProjectPath projectPath(Project? project) => if(exists p = project) then p.projectPath else ProjectPath.root;

shared TaskPath makeTaskPath(Project? project, String taskName) => TaskPath(projectPath(project), taskName);



shared abstract class Task (
	shared String name, 
	shared variable Project? project = null
)
	satisfies AbstractTask
{
	shared default {Input *} inputCacheElements = [];
	shared default {Output *} outputCacheElements = [];
	
	shared default Category? category = categories.byName(name);
	shared default String? description = null;
	
	shared TaskPath taskPath() => makeTaskPath(project, name);
	
	
	shared MutableList<Task> dependencies = ArrayList<Task>();
	shared MutableList<CacheElement> cacheElementDependencies = ArrayList<CacheElement>();
	
	
	shared void updateParent(Project ? newParent) {
		this.project = newParent;
		TaskPath tp = taskPath();
		inputCacheElements*.updateTaskPath(tp);
		outputCacheElements*.updateTaskPath(tp);
	}
	
	shared default void addDependency<T>(T task, {Attribute<T, CacheElement> *} attrs) given T satisfies Task {
		
		dependencies.add(task);
		
		for(attr in attrs) {
			CacheElement cacheElement = attr.bind(task).get();		
			cacheElementDependencies.add(cacheElement);
		}
	}
	
	/***
	shared default TaskExecutor<Result> executor => SimpleTaskExecutor<Result>(execute);
	
	shared actual default Error|TaskResult checkAndExecute(AbsolutePath projectRootPath) {
		return executor.execute(projectRootPath);
	}
	 */
	
}
