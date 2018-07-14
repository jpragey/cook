import ceylon.buffer.base {
	base64StringStandard
}
import org.cook.core.filesystem {
	RelativePath,
	AbsolutePath,
	Visitor
}
import ceylon.file {
	Nil,
	File,
	Directory
}
import ceylon.json {
	JsonArray,
	JsonObject
}
import org.cook.core {
	TaskPath,
	Error,
	ErrorBuilder
}

class FileTree(AbsolutePath basePath) {
	shared JsonArray jsonContent("From base" RelativePath startPath) {
		JsonArray result = JsonArray{};
		
		basePath.visit(startPath, object satisfies Visitor {
			shared actual Boolean beforeDirectory(RelativePath relativePath, Directory dir) {
				return true;
			}
			shared actual void file(RelativePath relativePath, File file) {
				Integer size = file.size;
				Byte[] content = file.Reader().readBytes(size);
				String contentStr = base64StringStandard.encode(content);
				value fileJson = JsonObject{
					"relPath" -> JsonArray{* relativePath.elementStrings},
					//"fname" -> file.name,
					//"type" -> "f",
					"content" -> contentStr
				};
				result.add(fileJson);
				
			}
		});
		
		return result;
	}
	
	shared Error|Boolean updateFrom(JsonObject content, TaskPath taskPath()) {
		//print(content.pretty);
		
		variable Boolean updated = false;
		ErrorBuilder errorBuilder = ErrorBuilder();
		
		if(exists outputFiles = content.getArrayOrNull("target")) {
			for(outputFile in outputFiles) {
				
				//print(" -- output file JSON: ``outputFile else "<null>"``");
				if( is JsonObject outputFile, 
					is JsonArray relPathJson = outputFile.getArrayOrNull("relPath"), 
					is String base64Content = outputFile.getStringOrNull("content")) 
				{
					RelativePath relPath = RelativePath(*relPathJson.strings);
					AbsolutePath path = basePath.append(relPath);
					
					//print(" -- output file: path = ``relPath``, content=``base64Content``");
					
					List<Byte> bytes = base64StringStandard.decode(base64Content);
					
					switch(resource = path.resource)
					case(is Nil) {
						updated = true;
						File file = resource.createFile(true);
						try (writer = file.Overwriter()){
							writer.writeBytes(bytes);
						}
					}
					case(is File) {
						// Check if changed
						try(reader = resource.Reader()) {
							List<Byte> existingBytes = reader.readBytes(resource.size);
							
							updated = (existingBytes != bytes);
							if(updated) {
								try (writer = resource.Overwriter()) {
									writer.writeBytes(bytes);
								}
							}
						}
						
					}
					else {
						errorBuilder.add("Error while updating output of task ``taskPath()`` from cache: resource for path ``path`` exists and is not a file (it's ``resource``)");
					}
				}
			}
		}
		
		if(errorBuilder.hasErrors) {
			return errorBuilder.build("``errorBuilder.count`` errors found while updating output of task ``taskPath()`` from cache.");
		} else {
			return updated;
		}
	}

}