---General library of awesomeness
--@module gma.ekincl.global
--@author Eric Kincl

gma.ekincl.global={}

---Split a string on a seperator
--Thanks StackOverflow!
--http://stackoverflow.com/questions/1426954/split-string-in-lua
gma.ekincl.global.strSplit = function (instr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(instr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end