
shared class Cursor(shared [String +] args) {
	
	shared Cursor? advance(Integer count = 1) => if(nonempty nextArgs = args[count...]) then Cursor(nextArgs) else null;
	
	shared String? lookahead(Integer count = 0) => args[count];
	
	shared String first => args.first;
	
}

