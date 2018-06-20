import ceylon.test {
	test,
	assertEquals,
	parameters
}
import org.cook.cli {
	BooleanOption,
	Parser
}

{[[String *], Boolean, Boolean] *} checkAdvanceByOneTestSets = {
		[[], false, false], 
		[["opt0"], true, false], 
		[["opt1"], false, true], 
		[["opt0", "opt1"], true, true]};

class BooleanOptionTest() 
{
	
	
	test
	parameters(`value checkAdvanceByOneTestSets`)
	shared void checkAdvanceByOne([String *] args, Boolean expectedOpt0, Boolean expectedOpt1) 
	{
		class Values(shared variable Boolean b0 = false, shared variable Boolean b1 = false){}
		BooleanOption<Values> opt0 = BooleanOption<Values>(["opt0"], (Values v)() {v.b0 = true; return null;});   
		BooleanOption<Values> opt1 = BooleanOption<Values>(["opt1"], (Values v)() {v.b1 = true; return null;});
		value parser = Parser<Values>(Values, {opt0, opt1});
		
		Values actual = assertNotError(parser.parse(args));
		assertEquals(actual.b0, expectedOpt0);
		assertEquals(actual.b1, expectedOpt1);
	}
	
	
	
}