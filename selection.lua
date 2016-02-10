---Library for dealing with the current selection
--@module gma.ekincl.selection
--@author Eric Kincl

--Don't find the selection of more than this...
hard_limit=20

gma.ekincl={}
gma.ekincl.selection={}

---Returns the currently selected fixtures as a table.
--Inspired by alm
--http://www.ma-share.net/forum/read.php?14,47511,47675#msg-47675
--@treturn table Table of currently selected fixtures.
gma.ekincl.selection.getSelection = function ()
	
	gma.feedback("Grabbing selection... Please stand by...");
	
	local gsg=gma.show.getobj;
	local ret={};
	local dim={};
	local dimnum=1;  --LUA isn't 0 indexed
	local fix={};
	local fixnum=1;  --LUA isn't 0 indexed
	
	--Use 3 groups
	--  Group1: Store ALL selection
	--  Group2: Store 1 fixture
	--  Group3: Copy of original Group1 - for restoring selection at the end.
	--  Store an "All" preset instead to restore the programmer?
	--    ...not sure this will actually clear the programmer...  Test.
	local groups = gma.ekincl.groups.getFreeGroup(3);
	local g1=groups[1];
	local g2=groups[2];
	local g3=groups[3];
	
	g1="Group "..g1;
	g2="Group "..g2;
	g3="Group "..g3;
	
	--Store current selection to Group 1&3
	
	gma.cmd("Store "..g1);
	gma.cmd("Copy "..g1.." At "..g3);
	
	local i=0;
	while i < hard_limit do  --Flow:
		gma.cmd("SelFix "..g1);  --Select Group1
debug("Selecting "..g1);

		local handleG1 = gsg.handle(g1);  --Get the handle of the g1.  (To detect finish)
		name = gsg.name(handleG1);
		name = gma.ekincl.global.strSplit(name);
		
		gma.show.getobj.compare(handleG1new, handleG1old) --Compare the handle this loop to last...
		
debug("Name:"..name[1]);
		if name[1] == "Group" or name[1] == "Dim" then  --If the name starts with "Group", we aren't on the last item yet.
debug("Next");
			gma.cmd("Next");  --NEXT to get single fixture
		end
		
		gma.cmd("Store "..g2.." /nc /o");  --Store to Group2
debug("Storing Group 2 "..g2);
		
		local handleG2 = gsg.handle(g2);  --Get the handle of the individual device's group
		if handleG2 == nil then  
			break;  --If the handle doesn't exist, the group was never created.  Something likely went wrong.  Exit.
		end
		
		local name = gsg.label(handleG2);	--Extract name from Group2 and add to return table.
		if name == "Empty" then
			break;  --If name=="Empty" or nil then we are done - clean up.
			--
		end
debug("Group 2's name: "..name);
		
		name=gma.ekincl.global.strSplit(name);
		if name[1] == "Dim" then
debug("Found Dim "..name[2]);
			dim[dimnum] = name[2];
			dimnum=dimnum+1;
		else
			fix[fixnum] = name[2];
			fixnum=fixnum+1;
		end
		
		--Following command is a LOT cleaner.  It *SHOULD* work.  It works from the command line.  It does not work from LUA.  :-(
		--gma.cmd("ClearAll");  --If we don't clear first it will delete the entire g1
		gma.cmd("ClearSelection");  --Does this work instead of ClearAll?
		gma.cmd("Delete "..g1.." Selection "..g2);  --Remove Group2 from Group1 (Delete Group2 fixture from Group1)
		gma.cmd("Delete "..g2); --Delete g2 when we are done with it.
		
		
		--We have a problem here... When using "Next" on the final item, it will actually advance to the next actual fixture rather than staying inside the group.
		--This leads to an infinite loop of never adding the final fixture but rather adding infinite of the fixture after the final one.
		--Possible solutions:
		--1. Check for 2 duplicate fixtures in a row, delete them both, then don't next for the final pass.
		--2. The name of "g1" auto-changes when it only has 1 member remaining
		
		
		i=i+1;  --Repeat...
	end
	
	--  Cleanup
	
	-- Compile return table.
	ret["dim"]=dim;
	ret["fix"]=fix;
	
	gma.echo("Dims:");
	for i,v in ipairs(dim) do
		gma.echo("i:"..i.." v:"..v);
	end
	
	gma.cmd(g3);  --Select Group3
gma.echo("About to delete groups... Check them now!");
gma.sleep(10);
	gma.cmd("Delete "..g1.." "..g2.." "..g3);  --Delete Group 1,2,3
	
	return ret;  --Return table
end


function debug(msg)
	gma.echo(msg);
	gma.sleep(1);
end