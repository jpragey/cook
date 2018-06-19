import org.cook.core.filesystem {
	AbsolutePath
}
import ceylon.file {
	current
}
import ceylon.collection {
	ArrayList
}
import org.cook.graph {
	IdentifiableGraph,
	Cycle
}




shared class Executor(
	//"Shell-type filter.
	//  * at start means any project
	//  * at end means any task
	//  "
	//String filterString,
	AbsolutePath projectRootPath = AbsolutePath(current),
	Console console = StdConsole(),
	""
	Integer successCode = 0,
	Integer errorCode = 1,
	//Anything (String ) writeError = console.error,
	//Anything (String ) writeMessage = console.info,
	String[] cliArgs = process.arguments
) 
{
	void dumpAllTasks(Project project, void describe(String txt)) {
		describe("All tasks:");
		project.visitTasks(object satisfies TaskVisitor{
			shared actual void before(Project project, Task<Anything> task) {
				describe("  ``project.projectPath`` ::: ``task.name``");	
			}
		}, true);
	}
	
	shared Integer execute(Project project) {
		
		Cli cli;
		
		switch(c = parseCli(cliArgs, process.writeLine))
		case(is Error) {
			c.printIndented(console.error);
			return errorCode;
		}
		case(is Null) {
			return successCode;
		}
		case(is Cli) {
			cli = c;
		}
		
		void describe(String txt) {
			if(cli.describe) {
				console.info(txt);
			}
			
		}
		
		if(cli.describe) {
			dumpAllTasks(project, describe);
		}
		
		ArrayList<Task<>> matchingTasks = ArrayList<Task<>>();
		
		if(nonempty filterStrings = cli.extraArgs) {
			
			value filters = [for(String filterString in filterStrings) TaskFilter(filterString)];
			
			Boolean matchAnyFilter(Task<> task) => 
					filters.find((TaskFilter f) => f.filter(task.taskPath())) exists;
			
			Task<>[] found = project.findTasks(matchAnyFilter);
			
//			console.debug("Matched tasks `` {for(t in found) "``t[1]``"} ``");
			matchingTasks.addAll(found);
			//}
		} else {
			console.error("No task found in command-line.");
			return errorCode;
		}
		
		// --describe: don't execute graph
		if(cli.describe) {
			return successCode;
		}
		
		switch(res = runTaskGraph(matchingTasks))
		case(is Null) {
			return successCode;
		}
		case(is Error) {
			res.printIndented(console.error);
			return errorCode;
		}
	}
	
	Error? runTaskGraph (List<Task<>>  tasks) {
		
		IdentifiableGraph<Task<>> graph = IdentifiableGraph<Task<>>(tasks, (task) => task.dependencies.sequence()); // TODO:optimize task.dependencies.sequence
		
		switch(sortedTasks = graph.sort {
			showCycle = true;
			keepNodesOrder = true;
		})
		case(is Cycle<Task<>>) {
			return Error("Task dependencies cycle found: ``sortedTasks.nodes*.name``");	// TODO: better explain cycle
		}
		case(is Task<>[]) {
			for(task in sortedTasks) {
				if(is Error err = task.execute(projectRootPath)) {
					return err;
				}
			}
		}
		
		return null;
	}
	
}



