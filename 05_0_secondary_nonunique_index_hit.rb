# update by non unique secondary index
# non unique secondary would lock gap if not hit

require 'active_record'
require 'faker'

require './utils/parallel_transaction'

def init
  Teacher.create( name: 'b', age: 10)
  Teacher.create( name: 'c', age: 12)
  Teacher.create( name: 'd', age: 17)
  Teacher.create( name: 'e', age: 20)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.where(age: 10).update_all(note: 'special')
    sleep 10.seconds
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 0.5.seconds
    Teacher.create(name: 'a', age: 9)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)