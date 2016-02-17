require 'SecureRandom'

class WsController < WebSocketRails::BaseController
	include Tubesock::Hijack
	
	##
	# Command identifier declarations. Every
	# message over a GuacamoleTunnel MUST always
	# start with one of these prefixes
	##
	@@READ_PREFIX = "read:"
	@@WRITE_PREFIX = "write:"
	@@CONNECT_PREFIX = "connect:"

	@@UUID_LENGTH = 36

	@@GuacTunnels = Hash.new


	def request
		hijack do |tubesock|
			tubesock.onmessage do |data|
				# New connection request
				if data.start_with?(CONNECT_PREFIX)
					tunnel = doConnect()
					registerTunnel(tunnel)
					tubesock.send_data(tunnel.uuid)
				
				# Write command
				elsif data.start_with?(WRITE_PREFIX)
					uuid = data[WRITE_PREFIX_LENGTH..WRITE_PREFIX_LENGTH + UUID_LENGTH]
					doWrite(data, tubesock, uuid)

				# Read request 
				elsif data.start_with?(READ_PREFIX)
					uuid = data[WRITE_PREFIX_LENGTH..WRITE_PREFIX_LENGTH + UUID_LENGTH]
					doRead(data, tubesock, uuid)
				end
			end
		end
	end

private
	
	# Create a new GuacamoleSocket and pass it
	# to a new GuacamoleTunnel
	def doConnect ()
		sock = GuacamoleSocket.new("127.0.0.1", 4822)
		uuid = SecureRandom.uuid
		tunnel = GuacamoleTunnel.new(uuid, socket)
		return tunnel
	end


	def doRead (data, tubesock, uuid)
		tunnel = GuacTunnels[uuid]

		unless tunnel.isConnected?
			raise GuacConnError, "Tunnel disconneted!"
		end

		tubesock.send_data(tunnel.read)
	end

	def doWrite (data, tubesock, uuid)
		tunnel = GuacTunnel[uuid]
		tunnel.write(data)
	end

	def registerTunnel(tunnel)
		GuacTunnels[tunnel.uuid] = tunnel
	end

	def deregisterTunnel(tunnel)
		GuacTunnels.delete(tunnel.uuid)
	end
end


class GuacamoleTunnel
	attr_accessor :uuid, :guacSocket

	# Unique identifier for each socket
	@uuid
	# The guacamole Socket to which it can write.
	@guacSocket

	def read
		return @guacSocket.socket.read
	end

	def write (data)
		@guacSocket.socket.write(data)
	end

	def initialize(uuid, guacamoleSocket)
		@uuid = uuid
		@guacSocket = guacamoleSocket
	end

	def isOpen
		@guacSocket.isConnected?
	end
end

require 'socket'

class GuacamoleSocket
	# The bare TCPSocket connected to
	# the guacamole daemon
	@socket

	def initialize (hostIp, port)
		begin
			@socket = TCPSocket.new(hostIp, port)

		rescue Errno::ETIMEDOUT
			# The connection request to guacd timed out!
			puts 'Connection request to Guacamole daemon timed out.'
			raise GuacConnError, 'Connection timed out!'

		rescue Errno::ECONNREFUSED
			# The target machine actively refused the incoming
			# connection. Guacd not running?
			puts 'Connection to Guacamole daemon actively refused.'
			raise GuacConnError, 'Connection Refused!'
		end
	end

	def isConnected?
		!socket.closed?
	end

	def close
		@socket.close
	end
end

class GuacamoleClientInformation
	attr_accessor :optimalScreenWidth
	attr_accessor :optimalScreenHeight
	attr_accessor :optimalResolution

	attr_accessor :audioMimetypes
	attr_accessor :videoMimetypes
	attr_accessor :imageMimetypes

	# The clients optimal screen dimensions in pixels
	@optimalScreenWidth = 1024
	@optimalScreenHeight = 768

	# Optimal resolution in DPI
	@optimalResolution = 98

	# The client suported mime types
	@audioMimetypes = []
	@videoMimetypes = []
	@imageMimetypes = []

	def initialize 
	end
end


class GuacamoleReader

end

class GuacamoleWriter

end

class GuacamoleInstruction
	attr_accessor :opcode, :args

	@opcode
	@args

	def initialize (opcode, *args)
		@opcode = opcode
		@args = Array.new

		args.each do |arg|
			args << arg
		end
	end

	def toString 
		str = StringIO.new

		# Write opcode
		str << opcode.length
		str << '.'
		str << opcode

		# Write arguments
		args.each do |arg|
			str << ","
			str << arg.length
			str << "."
			str << arg
		end

		# Write terminator
		str << ";"

		return str
	end
end

class GuacConnError < Exception
end
