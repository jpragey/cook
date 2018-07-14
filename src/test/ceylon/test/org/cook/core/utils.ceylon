import org.cook.core {
	Error,
	Failed
}
import ceylon.file {
	Directory,
	Nil,
	Path,
	File
}
import org.cook.core.filesystem {
	AbsolutePath
}

shared T assertNotError<T>(T|Failed|Error t) 
{
	void printError(Error error) {
		error.printIndented(print);
	}
	
	switch(t)
	case(is Error) {
		printError(t);
		throw AssertionError(t.message);
	}
	case(is Failed) {
		printError(t.cause);
		throw AssertionError(t.cause.message);
	}
	else {
		return t;
	}
}

shared interface TestEntry satisfies Destroyable {
	shared formal Path path;
	//		shared formal Path parentPath;
}

shared class TestDirEntry(Directory|TestDirEntry parent, shared String name/*, {TestEntry(TestEntry) *} children*/) satisfies TestEntry {
	shared /*actual*/ Path parentPath = if(is Directory parent) then parent.path else parent.path;
	shared actual Path path = parentPath.childPath(name);

	shared actual String string => path.string;
	
	shared AbsolutePath absolutePath(String* children) =>  AbsolutePath(path).add(*children);
	
	assert(is Nil res = parentPath.childPath(name).resource);
	Directory dir = res.createDirectory(true);
	
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
		if(is Directory d = dir.path.resource) {
			deepDelete(dir);
		}
	}
}


shared class TestFileEntry(Directory|TestDirEntry parent, String name, String|<Byte[]>? content = null) satisfies TestEntry {
	shared /*actual*/ Path parentPath = if(is Directory parent) then parent.path else parent.path;
	shared actual Path path = parentPath.childPath(name);
	
	shared actual String string => path.string;
	
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
		if(is File f = file.path.resource) {
			f.delete();
		}
	}
}
