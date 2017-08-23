class MyWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'myinstance-tosolve', auto_delete: true

  def perform(sqs_msg, body)
    puts "normal: #{body}"
    %x[/usr/local/bin/fibsqs #{body}]
  end
end

class MyFastWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'myinstance-tosolve-priority', auto_delete: true

  def perform(sqs_msg, body)
    puts "priority: #{body}"
    %x[/usr/local/bin/fibsqs #{body}]
  end
end
