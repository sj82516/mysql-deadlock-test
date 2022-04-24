# update by non unique secondary index
# https://dev.mysql.com/doc/refman/8.0/en/innodb-locks-set.html
# "For other search conditions, and for non-unique indexes,
#  InnoDB locks the index range scanned,
#  using gap locks or next-key locks to block insertions by other sessions into the gaps covered by the range."

require 'active_record'
require 'faker'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 1, name: 'aaa', age: 10)
  Teacher.create(id: 2, name: 'bbb', age: 12)
  Teacher.create(id: 3, name: 'c', age: 17)
  Teacher.create(id: 4, name: 'd', age: 20)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.where('age == 20').update_all(note: 'adult')
    sleep 10.seconds
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 0.5.seconds
    Teacher.create(name: Faker::Name.name)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)