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


shared ProjectPath projectPath(Project? project) => 
		project?.projectPath else ProjectPath.undefined 
		;

shared TaskPath makeTaskPath(Project? project, String taskName) =>
		TaskPath(projectPath(project), taskName);


shared abstract class Task (
	shared String name, 
	shared variable Project? project,
	shared variable Cache? cache = null
)
{
	shared default {Input *} inputCacheElements = [];
	shared default {Output *} outputCacheElements = [];
	
	shared default Category? category = categories.byName(name);
	shared default String? description = null;
	
	shared TaskPath taskPath() => makeTaskPath(project, name);
	
	shared MutableList<Task> dependencies = ArrayList<Task>();
	shared MutableList<CacheElement> cacheElementDependencies = ArrayList<CacheElement>();
	
	"null : not executed yet"
	shared variable <TaskResult|Null> lastResult = null;
	
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

	shared formal TaskResult execute(AbsolutePath projectRootPath);
	
	
	TaskResult executeWithCache(<TaskResult>(AbsolutePath) delegate) (AbsolutePath projectRootPath ) {
		// TODO: implement it
		return delegate(projectRootPath);
	}
	
	TaskResult checkDependenciesAndRun(TaskResult(AbsolutePath) delegate) (AbsolutePath projectRootPath ) {
		for(dep in dependencies) {
			switch(lastResult = dep.lastResult)
			case(is Null) {
				return Failed(Error("Internal error running ``taskPath()``: Dependency: ``dep.taskPath()`` was not evaluated."));
			}
			case(is TaskResult) {
				if(!lastResult.canContinue) {
					return lastResult;	// TODO: ???
				}
			}
		}

		return delegate(projectRootPath);
	}
	
	shared TaskResult checkAndExecute(AbsolutePath projectRootPath ) {
		
		variable<TaskResult>(AbsolutePath) runner = execute;
		
		if(exists c = cache) {
			runner = executeWithCache(runner);
		}
		runner = checkDependenciesAndRun(runner);
		
		
		value res = this.lastResult  = runner(projectRootPath);
		return res;
	}
	
}
