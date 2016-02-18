require 'Socket'

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

		rescue Errno::ECONNREFUSED
			# The target machine actively refused the incoming
			# connection. Guacd not running?
			puts 'Connection to Guacamole daemon actively refused.'
		end
	end

	def read
		return @socket.recv(2000)
	end

	def write(data)
		@socket.write(data)
	end

	def isConnected?
		!@socket.closed?
	end

	def close
		@socket.close
	end
end