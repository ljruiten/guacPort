require './GuacamoleInstructionParser'

class GuacamoleTunnel
	attr_accessor :uuid, :guacSocket
	@@connectString = "6.select,3.vnc;"
	# Unique identifier for each socket
	@uuid
	# The guacamole Socket to which it can write.
	@guacSocket
	# The configuration for this connection
	@guacConfig

	def doHandshake
		# Send the initial select protocol instruction
		write(@@connectString)
		# Read the response with the required arguments
		reqArgs = read
		p reqArgs
		# Make a GuacamoleInstruction of the response
		instr = GuacamoleInstructionParser.parseInstructionString(reqArgs)
		# Make a hash with the required arguments as keys
		# and empty strings as their values 
		instrMap = Hash.new
		instr.args.each do | arg |
			instrMap[arg] = ""
		end

		# Fill in the absolute required variables. Leaving the rest empty
		instrMap["hostname"] = "shipview.praxis-automation.nl"
		instrMap["port"] = "5906"
		instrMap["password"] = ""
		instrMap["read-only"] = ""


		# Turn the hash into a GuacamoleInstruction
		instr = GuacamoleInstruction.new("connect", instrMap.values)
		response = "5.audio,9.audio/ogg,9.audio/mp4,10.audio/mpeg,10.audio/webm,9.audio/wav;5.video,9.video/ogg,9.video/mp4,10.video/webm;"
		response << instr.toString.string
		p response
		# Send the instruction to Guacamole
		write(response)

		puts read
	end

	def read
		return @guacSocket.read
	end

	def write (data)
		@guacSocket.write(data)
	end

	def initialize(uuid, guacamoleSocket)
		@uuid = uuid
		@guacSocket = guacamoleSocket
	end

	def isOpen
		@guacSocket.isConnected?
	end
end