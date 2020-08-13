---Script to dump all GMA objects to a file.
--@module net.kincl.eric.grandma.tests.getAllObjects
--@author Eric Kincl
--@copyright 2020
--@license GNU GPL V2 http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
--@release 1.3


---Some default settings

--Default logfile Location
logfile="MAObjects.log";

--Log DMX/Patch by default?  (Warning - this takes a LONG time and LOTS of space!)
logdmx=false

-- Global the FilePointer.  Yes this is bad.  No I don't care right now.
fp=nil


---Entry-Point function.
function main()
  
  --How many parent objects should we search for?
  --There only apear to be ~40 parent objects to access, but knock yourself out!
  searchSize=gma.show.getobj.amount(1)+1
  
  -- Prompt user for the output file location
  logfile=gma.textinput("Output Filename",logfile);
  
  gma.echo("Dumping objects...");
  
  -- Initialize a progress bar
  local pb=gma.gui.progress.start("Dumping Objects");
  gma.gui.progress.setrange(pb,0,searchSize);
  
  -- Setup the file pointer
  fp=logSetup();
  
  -- GMA Lua doesn't appear to support for loops
  local i=0;
  while i<searchSize do
    -- Update the progress bar with the current item
    gma.gui.progress.set(pb,i);
    -- gma.echo("Searching ",i," of ",searchSize);
    
    -- Get the handle of the current object
    local handle=gma.show.getobj.handle(i)
    
    -- If handle is not null, scrape it.
    if handle~= nil then
      getAllObjects(handle,i);
    end
    
    i=i+1;
  end
  
  -- Close file
  logDestruct();
  
  -- Close Progress bar, log completion
  gma.gui.progress.stop(pb);
  gma.echo("Dump Complete!");
end



function getAllObjects(handle,breadcrumb)
  local gsg=gma.show.getobj
  local class=gsg.class(handle);
  local index=gsg.index(handle);
  local number=gsg.number(handle);
  local name=gsg.name(handle);
  local label=gsg.label(handle);
  local amount=gsg.amount(handle);
  
  log("-----Object-----");
  --if class==nil then
  --  class=""
  --end
  breadcrumb=breadcrumb.."-->"..class;
  log(breadcrumb);

  log("-----Object Info-----");
  log("   Index:",index);
  log("   Class:",class);
  log("    Name:",name);
  log("   Label:",label);
  log(" Cmd_Num:",number);
  log("Children:",amount);

  log("-----Properties-----");
  echoAllProperties(handle);

  if amount>0 then
    local pb=gma.gui.progress.start("Scanning: "..breadcrumb);
    gma.gui.progress.setrange(pb,0,amount);
    
    local i=0;
    while i<amount do
      gma.gui.progress.set(pb,i);
      local ch_handle=gsg.child(handle,i);
      if ch_handle~=nil then
        --Don't log all the DMX universes/channels unless explicitly asked
        if gsg.class(ch_handle)~="CMD_DMX_UNIVERSE" or logdmx == true then
          getAllObjects(ch_handle,breadcrumb);
        end
      end
      i=i+1;
    end
    gma.gui.progress.stop(pb);
  end

  log("\n\n");
end



function echoAllProperties(handle)
  amt=gma.show.property.amount(handle);
  if amt>0 then
    local i=0;
    while i<amt do
      log("Property[",i,"]: ",gma.show.property.name(handle,i),"=",gma.show.property.get(handle,i));
      i=i+1;
    end
  else
    log("No properties exist");
  end
end


---Open our logfile for writing
--
--@treturn filepointer File pointer of the file we opened.
function logSetup()
  local fp=assert(io.open(logfile, "w"));
  fp:write("Log open at ",gma.gettime());
  fp:write("\n");
  fp:flush();
  return fp;
end


---Closes the file we have open
--
--This function assumes a global variable for the file called "fp"
function logDestruct()
  fp:close();
  fp=nil;
end


---Write a line to the file we have open
--
--@tparam string string Multiple strings to be concatenated together and written to the logfile
function log(...)
  msg=concat(...);
  fp:write(msg);
  fp:write("\n");
  fp:flush();
end


---Concatenates multiple items together into a single string
--
--@tparam string Multiple items to concatenate together
--@treturn string Single concatenated string
function concat(...)
  local args={...}
  local msg=""
  for x,y in pairs(args) do
    msg=msg..y
  end
  return msg
end


-- We need to return the name of the main function to register it with GrandMA
return main;
