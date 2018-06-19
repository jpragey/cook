import ceylon.collection {
	ArrayList,
	MutableList
}

shared class Severity {
	shared String text;
	shared String fixedLengthText;
	shared Boolean errorType;
	
	shared new debug  {text = "DEBUG";   fixedLengthText = "DEBUG  "; errorType = false;}
	shared new info   {text = "INFO";    fixedLengthText = "INFO   "; errorType = false;}
	shared new warning{text = "WARNING"; fixedLengthText = "WARNING"; errorType = false;}
	shared new error  {text = "ERROR";   fixedLengthText = "ERROR  "; errorType = true;}
	shared new fatal  {text = "FATAL";   fixedLengthText = "FATAL  "; errorType = true;}
	
	//shared Anything(String) defaultPrinter(
	//	Anything writeLine(String text) => process.writeLine,
	//	Anything writeErrorLine(String text) => process.writeErrorLine
	//) 
	//{
	//	
	//}
}


shared interface Console 
{
	shared formal void message(Severity severity, String text, Throwable? cause = null);

	shared default void debug(String text)   => message(Severity.debug, text);
	shared default void info(String text)    => message(Severity.info, text);
	shared default void warning(String text) => message(Severity.warning, text);
	shared default void error(String text)   => message(Severity.error, text);
	shared default void fatal(String text)   => message(Severity.fatal, text);
}

shared class AccumulatingConsole(Console delegate, {Message *} initialMessages = {}) satisfies Console {
	
	shared class Message(shared Severity severity, shared String text, shared Throwable? cause) {}
	MutableList<Message> messages = ArrayList<Message>{*initialMessages};
	
	shared {Message *} actualMessages => messages;
	
	shared actual void message(Severity severity, String text, Throwable? cause) {
		messages.add(Message(severity, text, cause));
		delegate.message(severity, text, cause);
	}
}

shared class StdConsole(
	Anything (String) writeLine = process.writeLine,
	Anything (String) writeErrorLine = process.writeErrorLine
) satisfies Console {
	
	shared actual void message(Severity severity, String text, Throwable? cause) {
		Anything(String) write = severity.errorType then writeErrorLine else writeLine;
		write("``severity.fixedLengthText`` ``text``");	// TODO: write cause
	}
	
}


