# repeatable read would lock next key lock, include gap lock
# even update miss, transaction would still hold x mode gap lock
# insert cannot acquire insert intention lock
# by the way, the next key lock / insert intention lock would not block each other

require 'active_record'

require './utils/parallel_transaction'

def init
  # this would deadlock
  Teacher.create(id: 1, name: 'aaa', age: 10)
  Teacher.create(id: 2, name: 'bbb', age: 12)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.where(id: 6).update_all(age: 10)
    sleep 3.seconds
    Teacher.create(id: 6)
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.where(id: 10).update_all(age: 10)
    sleep 3.seconds
    Teacher.create(id: 10)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)