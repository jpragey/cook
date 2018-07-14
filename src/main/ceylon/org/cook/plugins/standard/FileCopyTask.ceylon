import ceylon.buffer.base {
	base64StringStandard
}
import ceylon.collection {
	ArrayList
}
import ceylon.file {
	Directory,
	File,
	Nil
}
import ceylon.json {
	JsonObject,
	JsonArray
}

import org.cook.core {
	Cache,
	Project,
	Task,
	TaskResult,
	Input,
	CacheId,
	Error,
	TaskPath,
	Success
}
import org.cook.core.filesystem {
	RelativePath,
	AbsolutePath,
	Visitor
}
shared class FileCopyTask(
	String name = "compileCeylon",
	
	Project? parentProject = null,
	Cache? cache_ = null

)
	extends Task(name, parentProject, cache_)
{
	ArrayList<CopyDir> copyDirs = ArrayList<CopyDir>(); 
	
	shared actual Input input => object satisfies Input {
		shared actual CacheId id() => CacheId(taskPath().elements);
		
		shared actual JsonObject|Error toJson(AbsolutePath root) {
			JsonArray filesJsArray = JsonArray{};
			
			variable Integer fCopyIndex = 0;
			for(copyDir in copyDirs) {
				filesJsArray.add(JsonObject{ (fCopyIndex++).string -> copyDir.toJson()});
			}
			
			value jsObj = JsonObject{
				"files" -> filesJsArray
			};
			return jsObj;
		}
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
	};
	
	
	//"Manages:
	// Input (state -> cache : JSON)
	// Input (state -> cache : compare)
	// Output (state -> cache : JSON)
	// Output (cache -> state: compare)
	// Output (cache -> state: parse JSON)
	// 
	// "
	//interface Snapshot {
	//	""
	//	shared formal JsonObject|Error inputToJson();
	//	shared formal Boolean|Error inputMatch();
	//	
	//	shared formal JsonObject|Error outputToJson();
	//	shared formal Boolean|Error outputMatch();
	//}
	
	//Snapshot snaptshot() {
	//	return object satisfies Snapshot {
	//		shared actual JsonObject createJson() {
	//			
	//		}
	//	};
	//	//return JsonObject{
	//	//	"copydirs" -> JsonArray{ *copyDirs*.toJson()}
	//	//};
	//}


	class CopyDir(shared AbsolutePath source, shared AbsolutePath target, shared Boolean createDir) {
		
		shared void execute() {
			doVisit {
				processDirectory = ("Relative to [[source]]]" RelativePath relativePath) {
					switch(res = target.append(relativePath).resource)
					case(is Directory) {/*Do nothing*/}
					case(is Nil) {
						res.createDirectory {includingParentDirectories = true;};
					}
					else {
						// TODO: error
					}
				};
				processFile = (RelativePath relativePath, File file) {
					switch(res = target.append(relativePath).resource)
					case(is Nil) {
						file.copy {target = res; copyAttributes = false;};
					}
					else {
						// TODO: error
					}
					
				};
			}; 
			
		}
		
		void doVisit(
			void processDirectory("Relative to [[source]]]" RelativePath relativePath), 
			void processFile(RelativePath relativePath, File file)) 
		{
			source.visit(RelativePath(), object satisfies Visitor {
				shared actual Boolean beforeDirectory(RelativePath relativePath, Directory dir) {
					processDirectory(relativePath);
					return true;
				}
				shared actual void file(RelativePath relativePath, File file) {
					processFile(relativePath, file);
				}
			} );
			
		}
		shared JsonObject toJson() {
			JsonArray filesJsArray = JsonArray{};
			
			void processDirectory("Relative to [[source]]]" RelativePath relativePath) {
				filesJsArray.add(JsonObject{
					"absPath" -> JsonArray{* source.append(relativePath).path.elements},
					//"fname" -> file.name,
					"type" -> "d"
				});
			}
			
			void processFile(RelativePath relativePath, File file) {
				Integer size = file.size;
				Byte[] content = file.Reader().readBytes(size);
				String contentStr = base64StringStandard.encode(content);
				value fileJson = JsonObject{
					"absPath" -> JsonArray{* source.append(relativePath).path.elements},
					//"fname" -> file.name,
					"type" -> "f",
					"content" -> contentStr
				};
				filesJsArray.add(fileJson);
				
			}
			
			doVisit(processDirectory, processFile);
			
			return JsonObject{
				"createDir" -> createDir,
				"fsEntries"-> filesJsArray
			};
		}
	}
	
	"Copy recursively [[source]] to [[target]].
	 If [[createDir]] is true, [[target]] is considered as a directory, and will be created if necessary; [[source]] will be copied in it.
	 If [[createDir]] is false, [[target]] is the same kind (file or directory) as [[source]].
	 "
	shared void copyDir(AbsolutePath source, AbsolutePath target, Boolean createDir = false) {
		copyDirs.add(CopyDir(source, target, createDir));
	}
	
	shared actual TaskResult execute(AbsolutePath root) {
		for(copyDir in copyDirs) {
			copyDir.execute();
		}
		return Success("");
	}
	
}