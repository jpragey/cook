import org.cook.cli { CliError = Error }

serializable
shared 
final 
class Error  
{
	shared String message;
	shared Error[] causes;
	shared Throwable? throwable;
	
	shared new (String message, Error[] causes = [], Throwable? throwable = null) {
		this.message = message;
		this.causes = causes;
		this.throwable = throwable;
	}
	
	shared new fromCli(CliError cause) 
		extends Error(cause.description, cause.causes.map(Error.fromCli).sequence())
		{}
	
	
	
	shared actual String string => message;

	shared void printIndented(Anything(String) write, Integer indentCount = 0) {
		String line = "`` " ".repeat(indentCount) ````message``"; 
		write(line);
		for(cause in causes) {
			cause.printIndented(write, indentCount + 1);
		}
	}
}
