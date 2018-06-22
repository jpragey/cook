native("jvm")

module test.org.cook.create "0.0.1" 
{
	value ceylonVersion = "1.3.3";
	import ceylon.test ceylonVersion;

	value cookVersion = "0.0.1";
	import org.cook.core cookVersion;
	import org.cook.plugins.standard cookVersion;
}
