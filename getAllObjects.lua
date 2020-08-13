---Script to dump all GMA objects to a file.
--@module net.kincl.eric.grandma.tests.getAllObjects
--@author Eric Kincl
--@release 1.2


--Logfile Location
--WARNING: This will overwrite any file existing here without asking!
--logfile="/Users/erick/Desktop/ma.log"
logfile="ma.log"

--How many parent objects should we search for?
--There only apear to be ~40 parent objects to access, but knock yourself out!
searchSize=gma.show.getobj.amount(1)+1


-- Global the FilePointer.  Yes this is bad.  No I don't care.
fp=nil


---Entry-Point function.
function main()
  gma.echo("Dumping objects...");
  fp=logSetup();
  local i=0;
  while i<searchSize do
    local handle=gma.show.getobj.handle(i)
    gma.echo("Searching ",i);
    if handle~= nil then
      getAllObjects(handle,i);
    end
    i=i+1;
  end
  logDestruct();
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
    local i=0;
    while i<amount do
      local ch_handle=gsg.child(handle,i);
      if ch_handle~=nil then
        --Don't log all the DMX universes/channels
        if gsg.class(ch_handle)~="CMD_DMX_UNIVERSE" then
          getAllObjects(ch_handle,breadcrumb);
        end
      end
      i=i+1;
    end
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


function logSetup()
  local fp=assert(io.open(logfile, "w"));
  fp:write("Log open at ",gma.gettime());
  fp:write("\n");
  fp:flush();
  return fp;
end


function logDestruct()
  fp:close();
  fp=nil;
end


function log(...)
  msg=concat(...);
  fp:write(msg);
  fp:write("\n");
  fp:flush();
  --No point in echoing - GMA log only holds about 50 of these entries at a time...
  --gma.echo(msg);
end


function concat(...)
  local args={...}
  local msg=""
  for x,y in pairs(args) do
    msg=msg..y
  end
  return msg
end


return main;
