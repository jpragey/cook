import ceylon.test {
	test,
	assertNull
}

import org.cook.core {
	Cli,
	parseCli
}
class CliTest() 
{
	test
	shared void printVersionTest() {
		variable String version = "";
		
		Cli? cli = assertNotError(parseCli( ["--version"], print, (String v){version = v;}));
		
		assertNull(cli);
		assert(version.size > 0);

	}
}