import org.cook.core.filesystem {
	RelativePath
}
shared class ProjectPath 
{
	"Names of projects, from root project"
	shared String[] projectNames;
	"Names of directories, from root project"
	shared String[] projectDirNames;
	
	shared new (String[] projectNames = [], String[] projectDirNames = projectNames) {
		this.projectNames = projectNames;
		this.projectDirNames = projectDirNames;
	}

	shared new root {
		this.projectNames = [];
		this.projectDirNames = [];
	}

	//shared ProjectPath append(String name) => ProjectPath(projectNames.append([name]));
	shared actual Boolean equals(Object that) {
		if (is ProjectPath that) {
			return projectNames==that.projectNames && 
				projectDirNames==that.projectDirNames;
		}
		else {
			return false;
		}
	}
	

	shared actual Integer hash {
		variable value hash = 1;
		hash = 31*hash + projectNames.hash;
		hash = 31*hash + projectDirNames.hash;
		return hash;
	}
	
	shared Boolean equalsPath(ProjectPath that) {
			return projectNames==that.projectNames;
	}
	
	shared actual String string =>":" + ":".join(projectNames);
	
	shared ProjectPath child(String projectName, String dirName = projectName) => 
			ProjectPath(projectNames.append([projectName]), projectDirNames.append([dirName]));
	
	shared RelativePath basePath = RelativePath(*projectDirNames);
}