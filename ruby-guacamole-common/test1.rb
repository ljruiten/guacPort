require "./GuacamoleInstructionParser"
require "./GuacamoleInstruction"

string = "8.connect,4.host,3.vnc;"
p GuacamoleInstructionParser.parseInstructionString(string)
