import ceylon.collection {
	ArrayList,
	HashMap
}
import ceylon.file {
	current
}

import org.cook.core.filesystem {
	AbsolutePath
}
import org.cook.graph {
	IdentifiableGraph,
	Cycle
}
import org.fusesource.jansi {
	Ansi,
	AnsiConsole
}


shared class Executor(
	AbsolutePath projectRootPath = AbsolutePath(current),
	Console console = StdConsole(),
	""
	Integer successCode = 0,
	Integer errorCode = 1,
	String[] cliArgs = process.arguments
) 
{
	shared void dumpAllTasks(Project project, void describe(String txt)) {
		//describe("All tasks:");
		AnsiConsole.systemInstall();
		
		class TaskInfo(shared String name, shared String? description) {}
		
		HashMap<Category, ArrayList<TaskInfo>> map = HashMap<Category, ArrayList<TaskInfo>> ();
		value unclassified = ArrayList<TaskInfo>(); 
		
		project.visitTasks(object satisfies TaskVisitor{
			shared actual void before(Project project, Task task) {
				String taskName = task.name;
				ArrayList<TaskInfo> list;
				if(exists category = task.category) {
					if(exists l = map.get(category)) {
						list = l;
					} else {
						list = ArrayList<TaskInfo>();
						map.put(category, list);
					}
				} else {
					list = unclassified;
				}
				String ? description = task.description;
				
				list.add(TaskInfo(taskName, description) );
				//describe("``project.projectPath`` - ``task.name``");	
			}
		}, true);
		
		void dumpCategory(String categoryName, ArrayList<TaskInfo> content) {
			if(content.empty) {
				return;
			}
			describe(categoryName);
			describe("-".repeat(categoryName.size));
			for(ti in content) {
				String s = Ansi.ansi()
						.fg(Ansi.Color.green).a(ti.name)
						.fg(Ansi.Color.yellow).a((if(exists d=ti.description) then " - ``d``" else ""))
						.reset().string;
				describe(s);
			}
		}
		for(cat->content in map) {
			dumpCategory(cat.name, content);
		}
		dumpCategory("unclassified", unclassified);
	}

	"
	 [[Error]]  if something went wrong
	 [[true]] if processed succesfully
	 [[false]] if it's not a predefined task.
	 "
	Error|Boolean dispatchPredefinedTasks(Project project, [String +] extraArgs) {
		
		switch(first = extraArgs.first)
		case("tasks") {
			dumpAllTasks(project, process.writeLine);
		}
		else {return false;}
		return true;
		
	}
	
	shared Integer execute(Project project) {
		
		if(exists err = project.checkSanity()) {
			err.printIndented(process.writeErrorLine);
			return errorCode;
		}
		
		Cli cli;
		
		switch(c = parseCli {
			cliArgs = cliArgs;
			writeHelp = process.writeLine;
			writeVersion = process.writeLine;
		})
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
			return successCode;
		}
		
		ArrayList<Task> matchingTasks = ArrayList<Task>();
		
		if(nonempty filterStrings = cli.extraArgs) {

			switch(res = dispatchPredefinedTasks(project, filterStrings)) 
			case(is Error){
				res.printIndented(console.error);
				return errorCode;
			}
			case(true) {return successCode;}
			else{}
			
			value filters = [for(String filterString in filterStrings) TaskFilter(filterString)];
			
			Boolean matchAnyFilter(Task task) => 
					filters.find((TaskFilter f) => f.filter(task.taskPath())) exists;
			
			Task[] found = project.findTasks(matchAnyFilter);
			
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
	
	Error? runTaskGraph (List<Task>  tasks) {
		
		IdentifiableGraph<Task> graph = IdentifiableGraph<Task>(tasks, (task) => task.dependencies.sequence()); // TODO:optimize task.dependencies.sequence
		
		switch(sortedTasks = graph.sort {
			showCycle = true;
			keepNodesOrder = true;
		})
		case(is Cycle<Task>) {
			return Error("Task dependencies cycle found: ``sortedTasks.nodes*.name``");	// TODO: better explain cycle
		}
		case(is Task[]) {
			for(task in sortedTasks) {
				
//				print(" -- task ``task.name ``parent: ``task.project?.name else "<null>"`` : taskpath = ``task.taskPath()``");
				
				if(is Error err = task.execute(projectRootPath)) {
					return err;
				}
			}
		}
		
		return null;
	}
	
}



