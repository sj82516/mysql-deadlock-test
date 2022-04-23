# secondary unique index would lock the corresponding clustered index

require 'active_record'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 2, name: 'd', age: 10)
  Teacher.create(id: 4, name: 'c', age: 15)
  Teacher.create(id: 5, name: 'b', age: 12)
  Teacher.create(id: 7, name: 'a', age: 15)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.order(:name).update_all(age: 10)
    sleep 10.seconds
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 1.seconds
    Teacher.order(:id).update_all(age: 10)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)