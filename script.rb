require 'active_record'

require './utils/connection'
require './utils/teacher'
require './utils/handle_deadlock'

def script(init:, t1:, t2:)
  init

  thread1 = Thread.new{ run(t1) }
  thread2 = Thread.new{ run(t2) }
  thread1.join
  thread2.join
end

def run(t)
  begin
    t.call
  rescue ActiveRecord::Deadlocked => e
    handle_deadlock
  end
end
