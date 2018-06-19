import org.cook.core.filesystem {
	RelativePath
}




shared class TaskPath(shared ProjectPath projectPath, shared String taskName) 
{
	shared String[] elements = projectPath.projectNames.append([taskName]);

	shared actual Boolean equals(Object that) {
		if (is TaskPath that) {
			return projectPath==that.projectPath && 
				taskName==that.taskName;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		variable value hash = 1;
		hash = 31*hash + projectPath.hash;
		hash = 31*hash + taskName.hash;
		return hash;
	}

	shared RelativePath basePath => projectPath.basePath;
	
	shared actual String string => projectPath.string + ":" + taskName;
	
}