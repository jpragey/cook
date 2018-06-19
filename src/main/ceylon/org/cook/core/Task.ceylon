import org.cook.core.filesystem {
	AbsolutePath
}
import ceylon.collection {
	MutableList,
	ArrayList
}
import ceylon.language.meta.model {
	Attribute
}
shared interface TaskChecker {
	shared formal Boolean mustExecute();
}






shared interface AbstractTask<out Result = TaskResult> given Result satisfies TaskResult {
	
	shared default Error|TaskResult checkAndExecute(AbsolutePath projectRootPath) {
		return execute(projectRootPath);
	}
	
	shared formal Error|TaskResult execute(AbsolutePath projectRootPath);
	
}

shared ProjectPath projectPath(Project? project) => if(exists p = project) then p.projectPath else ProjectPath.root;

shared TaskPath makeTaskPath(Project? project, String taskName) => TaskPath(projectPath(project), taskName);



shared abstract class Task<out Result = TaskResult>(
	shared String name, 
	shared variable Project? project = null
)
		satisfies AbstractTask<Result>
		given Result satisfies TaskResult
{
	//shared ProjectPath projectPath = if(exists p = project) then p.projectPath else ProjectPath.root;
	//
	//shared TaskPath taskPath = TaskPath(projectPath, name) ;
	
	shared formal {Input *} inputCacheElements;
	shared formal {Output *} outputCacheElements;
	
	
	shared TaskPath taskPath() => makeTaskPath(project, name);
	
	
	shared MutableList<Task<>> dependencies = ArrayList<Task<>>();
	shared MutableList<CacheElement> cacheElementDependencies = ArrayList<CacheElement>();
	
	
	shared void updateParent(Project ? newParent) {
		this.project = newParent;
		TaskPath tp = taskPath();
		inputCacheElements*.updateTaskPath(tp);
		outputCacheElements*.updateTaskPath(tp);
	}
	
	shared default void addDependency<T>(T task, {Attribute<T, CacheElement> *} attrs) given T satisfies Task<> {
		
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
