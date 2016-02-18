require './GuacamoleInstruction'

class GuacamoleInstructionParser
	def self.parseInstructionString (instruction)
		# Get opcode
		opcode = instruction.split(",")[0].split(".")[1]
		args = instruction.split(",")[1..-1].map{ |x| x.split(".")[1]}

		return GuacamoleInstruction.new(opcode, args)
	end

	# After the initial protocol select send by the client,
	# the server will respond with a list of the arguments it
	# expects from the client. The values of these arguments
	# can be empty, but the client needs to provide them all in 
	# the response.
	def self.parseHandShake(instructions)
		# Remove the trailing semi-column and
		# Split at every comma
		instrArr = instructions.chop!.split(",")

		# Make a map with all the required opcodes as keys
		# and their respective arguments as values.
		# The arguments are unknown at this time, so this only
		# returns a map with the keys and empty values.
		instrMap = Hash.new
		instrArr.each do |s|
			instrMap[s.split(".")[1]] = ""
		end

		return instrMap
	end

	def self.parseInstructionHash(hash)
		instruction = GuacamoleInstruction.new("connect", hash.values).toString
		puts instruction

		return instruction
	end
end
