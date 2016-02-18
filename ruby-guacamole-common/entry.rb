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

class GuacConnError < Exception
end