import org.cook.cli {
	Error
}

shared T assertNotError<T>(T|Error t ) {
	if(is Error t) {
		t.printIndented(print);
		throw AssertionError(t.description);
	}
	return t;
}

"Run the module `test.org.jpragey.ceylon.cli`."
shared void run() {
    
}