---Library for additional GUI items.
--@module gma.ekincl.gui
--@author Eric Kincl

gma.ekincl.gui={}

---Display a text-entry box and return the input.
--Note: Currently will ignore anything after the first space!
--@tparam string str Prompt to display to the user.
--@treturn string String with users input.  Note that any input after the first space is ignored and NOT returned.
gma.ekincl.gui.textbox = function (str)
  local tmpDTO;

  gma.cmd("SetUserVar $tmpDTO = ("..str..")");
  tmpDTO=gma.user.getvar("tmpDTO");
  return tmpDTO;
end
