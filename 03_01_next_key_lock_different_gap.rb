# next key lock in different gap
# would not deadlock

require 'active_record'

require './utils/parallel_transaction'

def init
  # would not deadlock, because gap is different
  Teacher.create(id: 2, name: 'aaa', age: 10)
  Teacher.create(id: 7, name: 'bbb', age: 12)
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