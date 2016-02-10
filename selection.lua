---Library for dealing with the current selection
--@module gma.ekincl.selection
--@author Eric Kincl

--Don't find the selection of more than this...
hard_limit=1000

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
	
	local nameOld=nil;
	local lastType=nil;
	
	--Store current selection to Group 1&3
	
	gma.cmd("Store "..g1);
	gma.cmd("Copy "..g1.." At "..g3);
	
	local i=0;
	while i < hard_limit do  --Flow:
		gma.cmd("SelFix "..g1);  --Select Group1
		gma.cmd("Next");  --NEXT to get single fixture
		gma.cmd("Store "..g2.." /nc /o");  --Store to Group2
		
		local handleG2 = gsg.handle(g2);  --Get the handle of the individual device's group
		
		if handleG2 == nil then  
			return nil;  --If the handle doesn't exist, the group was never created.  Something likely went wrong.  Exit.
		end
		
		local name = gsg.label(handleG2);	--Extract name from Group2 and add to return table.
		if name == "Empty" or name == nil then
			return nil;  --If name=="Empty" or nil then something went wrong.  Exit.
		end
		
		if name == nameOld then  --Check if we have "next"ed off the final unit and are looping continuously.
			--We have gotten to the end and stored an incorrect unit.
			--Remove the last stored unit, "prev", and store current.
			if lastType == "Dim" then
				dimnum=dimnum-1;
				dim[dimnum]=nil;  --Remove last entered dimmer item.
			elseif lastType == "Fix" then
				fixnum=fixnum-1;
				fix[fixnum]=nil;  --Remove the last entered fixture item.
			else
				return nil;  --No fixtures added somehow.  Error.
			end
			break;
		end
		nameOld = name;
		
		name=gma.ekincl.global.strSplit(name);
		if name[1] == "Dim" then
			lastType="Dim";
			dim[dimnum] = name[2];
			dimnum=dimnum+1;
		else
			lastType="Fix";
			fix[fixnum] = name[2];
			fixnum=fixnum+1;
		end
		
		gma.cmd("ClearSelection");
		gma.cmd("Delete "..g1.." Selection "..g2);  --Remove Group2 from Group1 (Delete Group2 fixture from Group1)
		gma.cmd("Delete "..g2); --Delete g2 when we are done with it.
		
		i=i+1;  --Repeat...
	end
	
	--  Cleanup/Final Store
	gma.cmd("Delete "..g2); --Delete g2
	gma.cmd("Previous");  --PREVIOUS to get the original fixture
	gma.cmd("Store "..g2.." /nc /o");  --Store to Group2

	local handleG2 = gsg.handle(g2);  --Get the handle of the individual device's group
	
	if handleG2 == nil then  
		return nil;  --If the handle doesn't exist, the group was never created.  Something likely went wrong.  Exit.
	end
	
	local name = gsg.label(handleG2);	--Extract name from Group2 and add to return table.
	if name == "Empty" or name == nil then
		return nil;  --If name=="Empty" or nil then something went wrong.  Exit.
	end
	
	name=gma.ekincl.global.strSplit(name);
	if name[1] == "Dim" then
		lastType="Dim";
		dim[dimnum] = name[2];
	else
		lastType="Fix";
		fix[fixnum] = name[2];
	end
	
	-- Compile return table.
	ret["dim"]=dim;
	ret["fix"]=fix;
	
	gma.cmd(g3);  --Revert original selection: Select Group3
	gma.cmd("Delete "..g1.." "..g2.." "..g3);  --Delete Group 1,2,3
	
	return ret;  --Return table
end


function debug(msg)
	gma.echo(msg);
	gma.sleep(1);
end