require 'active_record'

require './utils/connection'
require './utils/teacher'
require './utils/handle_deadlock'

Teacher.create(id: 1, name: 'aaa', age: 10)
Teacher.create(id: 5, name: 'bbb', age: 12)

def t1
  begin
    ActiveRecord::Base.transaction(isolation: :repeatable_read) do
      Teacher.where(id: 1).update(age: 15)

      sleep 3.seconds

      Teacher.where(id: 5).update(age: 10)
    end
  rescue ActiveRecord::Deadlocked => e
    handle_deadlock
  end
end

def t2
  begin
    ActiveRecord::Base.transaction(isolation: :repeatable_read) do
      Teacher.where(id: 5).update(age: 16)

      sleep 3.seconds

      Teacher.where(id: 1).update(age: 6)
    end
  rescue ActiveRecord::Deadlocked => e
    handle_deadlock
  end
end

t1 = Thread.new{ t1() }
t2 = Thread.new{ t2() }
t1.join
t2.join
