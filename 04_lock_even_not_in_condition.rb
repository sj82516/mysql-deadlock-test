# repeatable read would check row by index order
# it would lock row even the row is not satisfied where condition
# https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html#isolevel_repeatable-read
# "When using the default REPEATABLE READ isolation level, the first UPDATE acquires an x-lock on each row that it reads and does not release any of them"

require 'active_record'

require './utils/parallel_transaction'

def init
  # would not deadlock, because gap is different
  Teacher.create(id: 2, name: 'a', age: 10)
  Teacher.create(id: 3, name: 'b', age: 11)
  Teacher.create(id: 4, name: 'c', age: 18)
  Teacher.create(id: 100, name: 'd', age: 20)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :read_committed) do
    ActiveRecord::Base.connection.execute('update teachers use index (PRIMARY) set note="123" where id >= 3 and age = 40')
    sleep 5.seconds
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :read_committed) do
    sleep 0.5.seconds
    Teacher.where(id: 3).update_all(age: 15)
    # Teacher.create(id: 7, name: 'blocked!')
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)