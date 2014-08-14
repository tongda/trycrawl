require 'bunny'

conn = Bunny.new
conn.start

ch = conn.create_channel
q = ch.queue("test_queue")

q.publish("Hello, world.")

puts "Sent"

conn.close
