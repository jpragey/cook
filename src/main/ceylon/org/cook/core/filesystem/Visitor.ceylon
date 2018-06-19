import ceylon.file {
	File,
	Directory
}

shared interface Visitor {
	

	shared default Boolean beforeDirectory(RelativePath relativePath, Directory dir) => true;
	
	shared default void afterDirectory(RelativePath relativePath, Directory dir) {}
	
	shared default void file(RelativePath relativePath, File file) {}
}