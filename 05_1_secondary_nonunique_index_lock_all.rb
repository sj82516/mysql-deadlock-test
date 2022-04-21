# update by non unique secondary index
# by explain, it would use primary key and lock all the table
# be really careful when you batch update
# https://dev.mysql.com/doc/refman/5.7/en/innodb-transaction-isolation-levels.html

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
    ActiveRecord::Base.connection.execute('update teachers set teachers.note = "adult" where age = 20')
    sleep 10.seconds
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 0.5.seconds
    # Teacher.where(id: 1).update_all(note: "hihi")
    Teacher.create(name: Faker::Name.name)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)