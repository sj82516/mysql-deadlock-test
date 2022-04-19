# update multi record, innoDb would lock record one by one
# so index order is important

require 'active_record'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 2, name: 'aaa', age: 10)
  Teacher.create(id: 5, name: 'bbb', age: 12)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 3.seconds

    Teacher.where('id > 1').order(id: :asc).update_all(age: 10)
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 3.seconds

    Teacher.where('id > 1').order(id: :desc).update_all(age: 10)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)