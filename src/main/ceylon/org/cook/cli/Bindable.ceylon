shared interface BindableWithHelp<in Values, /*out Aux = Nothing, */out Help = String> 
		satisfies Bindable<Values/*, Aux*/> 
{
	shared formal Help help;
	shared formal Bindable<Values> delegate;
	
	shared default actual Bindable <Values> effectiveOption => delegate;
}

//shared interface WithChildrenHelp <out ChildrenHelp>{
//	shared formal {ChildrenHelp *} childrenHelp;
//}

shared interface Bindable <in Values/*, out Aux = Null*/> {
	shared formal BoundOption bind(Values values);
	
//	shared formal Aux? auxiliary;
	shared default Bindable <Values> effectiveOption => this;
	//Bindable<AppSettings> effectiveOption = if(is BindableWithHelp<AppSettings, CommandHelpTopic> option) then option.delegate else option;

	
	shared default BindableWithHelp<Values, /*Aux, */Help> withHelp<Help>(Help help_) => object satisfies BindableWithHelp<Values, /*Aux, */Help> {
		shared actual BoundOption bind(Values values) => outer.bind(values);
		
		shared actual Help help => help_;
		
		shared actual Bindable<Values> delegate => outer;
		
		
//		shared actual Aux? auxiliary => outer.auxiliary;
		
	};
}