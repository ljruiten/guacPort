require 'SecureRandom'
require './GuacamoleSocket'
require './GuacamoleTunnel'

uuid = SecureRandom.uuid
socket = GuacamoleSocket.new("159.100.67.188", 3456)
tunnel = GuacamoleTunnel.new(uuid, socket)

tunnel.doHandshake

