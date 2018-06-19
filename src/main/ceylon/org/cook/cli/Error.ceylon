shared final class Error(
	shared String description, 
	shared [Error *] causes = []) 
{
	shared actual Boolean equals(Object that) {
		if (is Error that) {
			return description==that.description && 
					causes==that.causes;
		}
		else {
			return false;
		}
	}
	
	shared actual String string => "Error[ \"``description``\", causes:``causes``]";
	
	shared void printIndented(Anything(String) write, Integer indentCount = 0, String indentString = " ") {
		String line = "`` indentString.repeat(indentCount) ````description``"; 
		write(line);
		for(cause in causes) {
			cause.printIndented(write, indentCount + 1);
		}
	}
}
