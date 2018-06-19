import ceylon.buffer {
	ByteBuffer
}
import ceylon.buffer.charset {
	utf8
}
import ceylon.collection {
	HashMap
}
import ceylon.file {
	File,
	Path,
	Nil
}
import ceylon.io {
	newOpenFile,
	OpenFile
}
import ceylon.json {
	JsonObject,
	JsonArray,
	parse
}

shared class DefaultCache satisfies Cache 
{
	//static MemoryCache fromFile() {} 

	HashMap<CacheId, JsonObject> content ;
	
	shared new ({<CacheId -> JsonObject> * } initialContent) {
		this.content = HashMap<CacheId, JsonObject>{*initialContent};
	}

	// TODO: be more strict with JSON syntax
	shared Error? loadString(String cacheJson) {
		if(is JsonArray array =  parse(cacheJson)) {	// throws Exception if invalid JSON
			
			for(JsonArray elementJson in array.arrays) {
				CacheId cacheId;
				value idStrings = elementJson.get(0);
				if(is JsonArray idStrings) {
					cacheId = CacheId(idStrings.strings.sequence());
					if(content.contains(cacheId)) {
						return Error("Cache format error, ID found twice: ``cacheId``");
					}
				} else {
					return Error("Json element for cache ID should be an Array, found ``idStrings else "<null>"``");
				}
				
				value jsonObject= elementJson.get(1);
				if(is JsonObject jsonObject) {
					this.content.put(cacheId, jsonObject);
				} else {
					return Error("Json for cacheId ``cacheId`` must be an object, found ``jsonObject else "<none>"``");
				}
			}
			return null;
		} else {
			return Error("Json root element is not an Array.");
		}
	}

	shared Error|String toJson(Boolean pretty = false) {
		value res = JsonArray{
			for(id->val in content) JsonArray{
				JsonArray (id.path),
				val
			}   
		};
		
		return if(pretty) then res.pretty else res.string;
	}
	
	shared Error? loadFile(Path cachePath) {
		switch(resource = cachePath.resource)
		case(is File) {
			OpenFile openFile = newOpenFile(resource);
			
			value decoder = utf8.cumulativeDecoder();
			openFile.readFully((ByteBuffer buffer) => decoder.more(buffer));
			
			String jsonText = decoder.done().string;
			Error? err = loadString(jsonText);
			return err;
		}
		else {
			return Error("Can't find a file ``cachePath``");
		}
	}
	
	shared Error? storeFile(Path path) {
		String|Error json = toJson();
		if(is Error json) {
			return json;
		}
		
		File file;
		switch(r = path.resource)
		case(is Nil) {
			file = r.createFile();
		}
		case(is File) {
			file = r;
		}
		else {
			return Error("Can't write cache file to ``path``, it exists soon and is not a regular file.");
		}
		
		try (over = file.Overwriter("UTF-8", 1M)) {
			over.write(json);
			return null;
		}
	}
	
	
	shared actual Boolean match(CacheElement[] currentCacheElements) {
		for(current in currentCacheElements) {
			
			switch(currentJson = current.toJson())
			case(is Error) {
				return false;	// TODO: dubious
			}
			case(is JsonObject) {
				CacheId id = current.id();
				if(exists JsonObject cachedJson = content.get(id)) {
					Boolean matched = (currentJson == cachedJson);
					if(!matched) {
						return false;
					}
				} else {
					// Not found in map
					return false;
				}
			} 
		}
		return true;
	}
	
	shared actual Error? updateFrom(CacheElement[] currentCacheElements) {
		for(current in currentCacheElements) {
			switch(val = current.toJson())
			case(is Error) {return val;}
			case(is JsonObject) {
				CacheId id = current.id();
				content.put(id, val);
			} 
		}
		
		return null;
	}
	
	shared actual Error? updateTo(Output[] currentCacheElements) {
		for(current in currentCacheElements) {
			CacheId id = current.id();
			if(exists JsonObject jsonObject = content.get(id)) {
				current.updateCache(jsonObject);
			} else {
				return Error("");
			}
		}
		return null;
	}
	
}