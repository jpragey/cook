shared class TaskFilter(String filterString/*, Console console*/) {
	
	//shared Boolean filter() {
	//console.debug("Processing task filter ``filterString``");
	
	[String +] parts = filterString.split(':'.equals).sequence();
	
	
	Boolean (TaskPath) taskFilterFor(String taskName) {
		if(taskName == "*") {
			return (TaskPath task) => true;
		} else {
			return (TaskPath task) => task.taskName == taskName;
		}
	}
	Boolean (ProjectPath) projectPathFilterFor(String[] filterString) {
		if(filterString == ["*"]) {
			return (ProjectPath projectPath) => true;
		} else {
			//String[] projectPathParts = filterString.split(".".equals).sequence();
			return (ProjectPath projectPath) => projectPath.projectNames == filterString;
		}
	}
	
	Boolean (TaskPath ) taskFilter;
	Boolean (ProjectPath ) projectPathFilter;
	
	if(parts.size == 1) {
		String taskName = parts[0];
		taskFilter = taskFilterFor(taskName); 
		projectPathFilter = (ProjectPath projectPath) => true; 
	} 
	else if(parts.size >1, exists String taskName = parts[parts.size-1], nonempty projectNames = parts[0:parts.size-1])
	{
		taskFilter = taskFilterFor(taskName); 
		projectPathFilter = projectPathFilterFor(projectNames); 
	} else {
		// Compile all
		projectPathFilter = (ProjectPath projectPath) => true; 
		taskFilter = (TaskPath task) => true; 
	}
	
	//	[Task<>, TaskPath][] found = project.findTasks((Task<> task, ProjectPath projectPath) => taskFilter(task) && projectPathFilter(projectPath));
	//	return true;
	//}
	//shared Boolean filter(Task<> task, ProjectPath projectPath) => taskFilter(task) && projectPathFilter(projectPath);
	shared Boolean filter(TaskPath taskPath) => 
			taskFilter(taskPath) && projectPathFilter(taskPath.projectPath);
	
}