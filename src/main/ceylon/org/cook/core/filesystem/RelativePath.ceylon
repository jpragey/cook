import ceylon.file {
	Path
}

shared abstract class Parent() of parent {
	shared actual String string => "..";
}
shared object parent extends Parent() {}

shared abstract class Current() of current {
	shared actual String string => ".";
}
shared object current extends Current() {}
shared alias PathElement => String|Current|Parent;

shared class RelativePath satisfies Summable<RelativePath> {

	shared static RelativePath parse(String path) {
		{PathElement *} elements = path.split( or('/'.equals, '\\'.equals) )
				.filter(not(String.empty))
				.map((String s) => s.trim(' '.equals))
				.map((String element) => 
					switch(element)
					case(".") current
					case("..") parent
					else element);
		
		return RelativePath(*elements);
	}

	shared PathElement[] elements;
	
	shared new (<PathElement>* elements) {
		this.elements = elements;
	}
	
	shared late String[] elementStrings = elements
			.map((PathElement element) => 
				switch(element) 
				case(is Current) "." 
				case(is Parent) ".." 
				else element)
			.sequence();
	
	shared actual Boolean equals(Object that) {
		if (is RelativePath that) {
			return elements==that.elements /*&& 
				elementStrings==that.elementStrings*/;
		}
		else {
			return false;
		}
	}
	shared actual Integer hash {
		variable value hash = 1;
		hash = 31*hash + elements.hash;
		//hash = 31*hash + elementStrings.hash;
		return hash;
	}
	
	shared RelativePath append(<PathElement>* others) => RelativePath(*elements.append(others)); 
	shared RelativePath appendPath(RelativePath other) => RelativePath(*elements.append(other.elements));
	shared Path from(Path path) {
		variable Path p = path;
		for(element in elements) {
			switch(element)
			case(is String) {p = p.childPath(element);}
			case(is Parent) {p = p.parent;}
			case(is Current) {}
		}
		return p;
	}
	
	shared actual RelativePath plus(RelativePath other) => this.appendPath(other);
	
	shared actual String string => "/".join(elements);
}