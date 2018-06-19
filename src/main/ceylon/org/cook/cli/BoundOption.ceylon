shared interface BoundOption {
	"Match a single argument with optionnal parameters.
	 Returns:
	 - [[Accepted]] if matched; [[Accepted.nextCursor]] must refer to the *next*
	   CLI argument (skipping option parameters, if any)
	 - [[Ignored]] if not matched at all (parser will try other [[BoundOption]]s)
	 - [[Error]] if option was matched but parsing failed, eg because of an invalid option parameter. 
	 "
	shared formal Accepted /*match*/ | Ignored | Error parseArgument(Cursor cursor);
}