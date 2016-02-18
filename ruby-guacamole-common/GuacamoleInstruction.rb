class GuacamoleInstruction
	attr_accessor :opcode, :args

	@opcode
	@args

	def initialize (opcode, args)
		@opcode = opcode
		@args = Array.new

		args.each do |arg|
			@args << arg
		end
	end

	def toString 
		str = StringIO.new

		# Write opcode
		str << opcode.length
		str << '.'
		str << opcode

		unless args == []
			# Write arguments
			args.each do |arg|
				str << ","
				str << arg.length
				str << "."
				str << arg
			end
		end

		# Write terminator
		str << ";"

		return str
	end
end