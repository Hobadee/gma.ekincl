---Library to do stuff with presets.
--@module gma.ekincl.presets
--@author Eric Kincl

gma.ekincl.presets={}

---Gets 1 or more free preset locations of a specific type.
--Known Bugs:
--I don't do sanity checking on the number of presets.  If you request more presets than are available (10k I think?!) this will probably fail in bad ways.
--Then again, if you have 10k presets, your show is probably failing in other bad ways as it is....
--
--If you specify a preset by number and the number is invalid, this will happily spit back available "presets".  Specify type by string if you can't count from 0-9.
--
--This function won't look into the presets at all; If you have a preset stored but without any actual info in it, this function will consider that "taken" and skip over it.
--@tparam string|number ptype Type of preset to get, identified by either it's number or name.
--@tparam ?number pnum Number of presets to find.  Default is 1.
--@tparam ?bool pcont Find a continuous block of presents, or whatever comes first which may be fragmented?  Defaults to fragmented.
--@treturn table|nil Table of preset numbers which are available.  If you specify an incorrect type string, returns nil.
gma.ekincl.presets.getFreePreset = function (ptype, pnum, pcont)

	--Default values for args.
	--Ideally these would be in the functions argument list as defaults... GMA doesn't seem to like that.
	if pnum == nil then
		pnum=1;
	end
	if pcont == nil then
		pcont=false;
	end

	--If ptype is a string, convert to a number.
	if type(ptype)=="string" then
		ptype=gma.ekincl.presets.getTypeNumber(ptype);
		if ptype==nil then
			return nil;  --If we can't find 
		end
	end
	
	local presets={}
	local i=1;  --Presets start at 1!
	local found=0;
	
	while found < pnum do
		local search = "PRESET " .. ptype .. "." .. i;  --Compile the search string
		local handle = gma.show.getobj.handle(search);  --Attempt to get a handle
		if handle == nil then  --If the handle doesn't exist, we have found and empty preset!
			presets[found+1] = i;  --LUA doesn't 0-ref it's tables.
			found=found+1;
		elseif pcont then  --If we find a taken handle and pcont is set, reset found to 0 and keep on going!
			found=0;
		end
		i=i+1;
	end
	return presets;
end


---Gets a preset type number by its name.
--@tparam string pname Name of the preset type we want to find the number of.  Case-sensitive, first letter capatalized.
--@treturn number|nil Number of the preset type we were searching.  nil if nothing is found.
gma.ekincl.presets.getTypeNumber = function (pname)
	local names = {["All"] = 0,
				   ["Dimmer"] = 1,
				   ["Position"] = 2,
				   ["Gobo"] = 3,
				   ["Color"] = 4,
				   ["Beam"] = 5,
				   ["Focus"] = 6,
				   ["Control"] = 7,
				   ["Shapers"] = 8,
				   ["Video"] = 9};
	return names[pname];
end

