import ceylon.file {
	Path,
	Resource,
	File,
	Directory
}

serializable
shared class AbsolutePath(shared Path path) {

	shared AbsolutePath append(RelativePath other) => AbsolutePath(
		other.elements.fold(path)( (path, String|Current|Parent child) => path.childPath(child.string) )	
	);
	
	shared Resource resource => path.resource; 

	shared void visit(RelativePath relativePath, Visitor visitor) {
		
		void visitDirectory(RelativePath relativePath, Directory dir) {
			
			visitor.beforeDirectory(relativePath, dir); 
			
			for(child in dir.children()) {
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