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
import ceylon.json {
	JsonObject
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
	//shared default {Input *} inputCacheElements = [];
	//shared default {Output *} outputCacheElements = [];
	
	
	shared default Category? category = categories.byName(name);
	shared default String? description = null;
	
	shared TaskPath taskPath() => makeTaskPath(project, name);

	shared default Input input => object satisfies Input {
		shared actual CacheId id() => CacheId(concatenate(taskPath().elements, ["in"]));
		
		shared actual JsonObject|Error toJson(AbsolutePath root) => JsonObject{};
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
	};
	
	shared default Output output => object satisfies Output {
		shared actual CacheId id() => CacheId(concatenate(taskPath().elements, ["out"]));
		
		shared actual JsonObject|Error toJson(AbsolutePath root) => JsonObject{};
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
		
		shared actual Error|Boolean updateFrom(JsonObject content, AbsolutePath root) => false;	// TODO: ???
		
	};
	
	shared MutableList<Task> dependencies = ArrayList<Task>();
	shared MutableList<Task> runAfterTasks = ArrayList<Task>();
	shared MutableList<CacheElement> cacheElementDependencies = ArrayList<CacheElement>();
	
	" - null : not executed yet
	  - Success : executed 
	  - Failed : executed, failed (including if a dependency failed)
	 "
	shared variable <TaskResult|Null> lastResult = null;
	
	shared void updateParent(Project ? newParent) {
		this.project = newParent;
		TaskPath tp = taskPath();
		input.updateTaskPath(tp);
		output.updateTaskPath(tp);
	}
	
	shared default void addDependency<T>(T task, {Attribute<T, CacheElement> *} attrs) given T satisfies Task {
		
		dependencies.add(task);
		
		for(attr in attrs) {
			CacheElement cacheElement = attr.bind(task).get();		
			cacheElementDependencies.add(cacheElement);
		}
	}
	shared default void runAfter(Task task) {
		runAfterTasks.add(task);
	}

	shared formal TaskResult execute(AbsolutePath projectRootPath);
	
	
	TaskResult executeWithCache(<TaskResult>(AbsolutePath) delegate) (AbsolutePath projectRootPath ) {
		variable TaskResult taskResult;
		
		if(exists cache = this.cache) {
			if(cache.match(input, projectRootPath)) { // 
				switch(updated = cache.updateTo(output, projectRootPath))
				case(is Error) {
					taskResult = Failed(Error("Error updating cache to (disk) data, task ``taskPath()``", [updated])); 
				}
				case(is Boolean) {
					taskResult = FromCache(updated);
				}
//
//				if(exists err = cache.updateTo(output, projectRootPath)) {
//					taskResult = Failed(Error("Error updating cache to (disk) data, task ``taskPath()``", [err])); 
//				} else {
//					taskResult = fromCache;
//				}
			} else {
				
				if(exists err = cache.updateFrom(input, projectRootPath)) {
					taskResult = Failed(Error("Error updating cache from (disk) data, task ``taskPath()``", [err])); 
				} else {
					taskResult = delegate(projectRootPath);
					
					if(exists err = cache.updateFrom(output, projectRootPath)) {
						taskResult = Failed(Error("Error updating cached task output from (disk) data, task ``taskPath()``", [err])); 
					}
				}
			}
		} else {
			taskResult = delegate(projectRootPath);
		}
		
		
		return taskResult;
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
	
	" Execution algo:
	 - Check if dependant tasks have been succesfully executed.
	 "
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
