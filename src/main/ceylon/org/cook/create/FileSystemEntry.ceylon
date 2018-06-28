import ceylon.file {
	Path,
	File,
	Nil,
	Directory
}

shared interface FileSystemEntry satisfies Destroyable {
	shared formal Path path;
	shared default actual String string => path.string;
}

shared class DirEntry(
	Directory|DirEntry parent, shared String name/*, {TestEntry(TestEntry) *} children*/
) satisfies FileSystemEntry 
{
	shared /*actual*/ Path parentPath = if(is Directory parent) then parent.path else parent.path;
	shared actual Path path = parentPath.childPath(name);
	
	
	assert(is Nil res = parentPath.childPath(name).resource);
	res.createDirectory(true);
	
	//TestEntry[] child = [for(c in children) c(super)];
	
	void deepDelete(Directory dir) {
		//Directory dir
		dir.childDirectories().each(deepDelete);
		for(res in dir.children()) {
			switch(res)
			case(is Directory) {deepDelete(res);}
			case(is File) {res.delete();}
			else{}
		}
		dir.delete();
	}
	
	shared actual void destroy(Throwable? error) {
		//deepDelete(dir);
	}
}


shared class FileEntry(Directory|DirEntry parent, String name, String|<Byte[]>? content = null) satisfies FileSystemEntry {
	shared /*actual*/ Path parentPath = if(is Directory parent) then parent.path else parent.path;
	shared actual Path path = parentPath.childPath(name);
	
	assert(is Nil res = path.resource);
	File file = res.createFile(true);
	if(exists content) {
		try(writer = file.Overwriter("utf-8", 10_000)) {
			if(is String content) {
				writer.write(content);
			} else {
				writer.writeBytes(content);
			}
		}
		
	}
	
	
	shared actual void destroy(Throwable? error) {
		//file.delete();
	}
}
