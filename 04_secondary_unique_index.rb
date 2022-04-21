# repeatable read would lock next key lock, include gap lock
# even update miss, transaction would still hold x mode gap lock
# insert cannot acquire insert intention lock
# by the way, the next key lock / insert intention lock would not block each other

require 'active_record'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 2, name: 'aaa', age: 10)
  Teacher.create(id: 4, name: 'ddd', age: 15)
  Teacher.create(id: 5, name: 'ccc', age: 12)
  Teacher.create(id: 7, name: 'bbb', age: 15)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :read_committed) do
    Teacher.where(name: 'ccc').update_all(age: 10)
    sleep 3.seconds
    Teacher.where(name: 'aaa').update_all(age: 10)
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :read_committed) do
    Teacher.where(id: 2).update_all(age: 15)
    sleep 3.seconds
    Teacher.where(id: 7).update_all(age: 15)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)