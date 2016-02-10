---Library to do stuff with groups.
--@module gma.ekincl.groups
--@author Eric Kincl

gma.ekincl.groups={}

---Gets 1 or more free group locations.
--Known Bugs:
--This function won't look into the groups at all; If you have a group stored but without any actual info in it, this function will consider that "taken" and skip over it.
--@tparam ?number pnum Number of groups to find.  Default is 1.
--@tparam ?bool pcont Find a continuous block of groups, or whatever comes first which may be fragmented?  Defaults to fragmented.
--@treturn table|nil Table of group numbers which are available.  If you specify an incorrect type string, returns nil.
gma.ekincl.groups.getFreeGroup = function (gnum, gcont)

	--Default values for args.
	--Ideally these would be in the functions argument list as defaults... GMA doesn't seem to like that.
	if gnum == nil then
		gnum=1;
	end
	if gcont == nil then
		gcont=false;
	end

	local groups={}
	local i=1;  --Groups start at 1!
	local found=0;
	
	while found < gnum do
		local search = "GROUP " .. i;  --Compile the search string
		local handle = gma.show.getobj.handle(search);  --Attempt to get a handle
		if handle == nil then  --If the handle doesn't exist, we have found and empty preset!
			groups[found+1] = i;  --LUA doesn't 0-ref it's tables.
			found=found+1;
		elseif gcont then  --If we find a taken handle and gcont is set, reset found to 0 and keep on going!
			found=0;
		end
		i=i+1;
	end
	return groups;
end
