require 'rubygems'
require 'em-websocket'
require 'drb'

require 'yaml'

credential_file = '.twitter'

usage = <<-EOF
  #{credential_file} is missing. Add the file with the following format
:username: USERNAME
:password: PASSWORD
EOF

raise usage unless File.exist? credential_file

credentials = YAML.load_file(credential_file)
username = credentials[:username]
password = credentials[:password]

raise "username and password are not set properly" unless username && password

port = ARGV.shift # eg: 22345

raise "specify port" unless port

begin
start = Time.now

class Channel
  def initialize
    @events = []
    @size = 0
  end

  def push(message)
    @events.each { |event| event.call(message) }
  end

  def subscribe(&event)
    @events << event
    @size += 1
  end

  def unsubscribe(event)
    @events.delete_at(@size)
    @size -= 1
  end
end
@channel = Channel.new
DRb.start_service("druby://localhost:#{port}", @channel)
DRb.thread.join
# EventMachine.run{
#   puts 'qqwe'
#   # @twitter = Twitter::JSONStream.connect(
#   #   :path => '/1/statuses/filter.json?track=a',
#   #   :auth => "#{username}:#{password}"
#   # )
#   #
#   # @twitter.each_item do |status|
#   #   @channel.push status
#   # end
# }

rescue Exception => e
  p "start: #{start} end:#{Time.now}"
  p e
  raise
end
