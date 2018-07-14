import ceylon.file {
	Path,
	Resource,
	File,
	Directory,
	ExistingResource,
	Link,
	currentDir = current
}

serializable
shared class AbsolutePath {
	shared Path path;
	
	shared new (Path path) {
		this.path = path;
	}
	shared new current extends AbsolutePath(currentDir) {}

	shared AbsolutePath append(RelativePath other) => AbsolutePath(
		other.elements.fold(path)( (path, String|Current|Parent child) => path.childPath(child.string) )	
	);
	
	
	shared Resource resource => path.resource; 

	shared AbsolutePath add(String* others) {
		variable AbsolutePath result = this;
		for(p in others) {
			result = result.append(RelativePath.parse(p));
		}
		return result;
	}
	//other.fold(this)( (path, String child) => path.append(RelativePath() )	
	//);

	shared void visit(RelativePath relativePath, Visitor visitor) {
		
		void visitDirectory(RelativePath relativePath, Directory dir) {
			
			visitor.beforeDirectory(relativePath, dir); 
			
			Comparison comparing (ExistingResource x, ExistingResource y) {
				String xName = switch(x)
				case(is Directory) x.name
				case(is File) x.name
				case(is Link) "";	// TODO
				
				String yName = switch(y)
				case(is Directory) y.name
				case(is File) y.name
				case(is Link) "";	// TODO
				
				return xName <=> yName;
			}
			
			for(child in dir.children().sequence().sort(comparing)) {
				switch(child)
				case(is File) {
					visitor.file(relativePath.append(child.name), child); 
				}
				case(is Directory) {
					visitDirectory(relativePath.append(child.name), child);
				}
				else {
					// TODO: error ?
				}
			}
			
			visitor.afterDirectory(relativePath, dir); 
		}
		
		//void visitDirectory(RelativePath relativePath, Directory dir);
		
		value startPath = AbsolutePath(path).append(relativePath);
		
		switch(resource = startPath.resource)
		case(is File) {
			visitor.file(relativePath, resource); 
		}
		case(is Directory) {
			visitDirectory(relativePath, resource);
		}
		else {
			// TODO: error ?
		}
	}
	
	shared actual String string => path.string;
}