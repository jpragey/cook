import ceylon.test {
	test
}

import org.jpragey.ceylon.cli {
	Bindable,
	CommandOption,
	StringOption,
	BindableWithHelp
}
class CommandOptionTest() 
{
	
	
	test
	shared void subOptionHelpTest() {
		class CommandValue(){
			shared variable String? stringOption0 = null;
			shared variable String? stringOption1 = null;
		}
		class Values(){
			shared variable CommandValue? commandValue = null;
		}
		
		class SubOptionHelp(shared String text = ""){}
		//class SubOptionHelp1(shared String text = ""){}
		
		value stringOpt0 = StringOption([], (CommandValue v)(String s) {v.stringOption0 = s; return null;})
			.withHelp(SubOptionHelp("Help on stringOpt0"));
		value stringOpt1 = StringOption([], (CommandValue v)(String s) {v.stringOption1 = s; return null;})
			.withHelp(SubOptionHelp("Help on stringOpt1"));
		
		/*value commandOption = */CommandOption<Values, CommandValue/*, SubOptionHelp1*/>{
			names = "theCommand";
			CommandValue createValues(Values v) => v.commandValue = CommandValue();
			bindOptions = {
				stringOpt0, 
				stringOpt1
			};
		};
		
		{Bindable<CommandValue/*, SubOptionHelp*/> *} bindOptions = {stringOpt0, 
				stringOpt1};

		value commandHelps = bindOptions.narrow<BindableWithHelp<CommandValue, SubOptionHelp>>()*.help;
		print("commandHelps: ``commandHelps``");
		

	}
	
}