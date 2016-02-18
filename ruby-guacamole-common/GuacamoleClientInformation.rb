class GuacamoleClientInformation
	attr_accessor :optimalScreenWidth
	attr_accessor :optimalScreenHeight
	attr_accessor :optimalResolution

	attr_accessor :audioMimetypes
	attr_accessor :videoMimetypes
	attr_accessor :imageMimetypes

	# The clients optimal screen dimensions in pixels
	@optimalScreenWidth
	@optimalScreenHeight

	# Optimal resolution in DPI
	@optimalResolution

	# The client suported mime types
	@audioMimetypes
	@videoMimetypes
	@imageMimetypes

	def initialize (osw = 1024, osh = 768, optR = 98, 
					aM = [], vM = [], iM = [])
	end
end