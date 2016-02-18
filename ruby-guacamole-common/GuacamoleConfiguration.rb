class GuacamoleConfiguration
	attr_accessor :paramsHash

	@paramsHash

	def set_parameter (key, value)
		@parameters[key] = value;
	end

	def initialize
		@paramaters = hash.new
	end
end