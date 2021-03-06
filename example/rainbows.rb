
worker_processes 4 # assuming four CPU cores
preload_app      true

Rainbows! do
  use :EventMachine, :em_client_class => lambda{
    RainbowsEventMachineFiberClient
  }
  worker_connections        100

  client_max_body_size      20*1024*1024 # 20 megabytes
  client_header_buffer_size  8*1024      #  8 kilobytes
end

require 'rest-more'
::RC::Builder.default_app = ::RC::Auto

class RainbowsEventMachineFiberClient < Rainbows::EventMachine::Client
  def app_call input
    Fiber.new{ super }.resume
  end
end

EM.error_handler{ |e|
  puts "Error: EM.error_handler: #{e.inspect} #{e.backtrace.inspect}"
}
