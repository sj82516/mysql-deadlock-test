# basic: you hold what I wait for and I hold what you wait for
# how to analyze deadlock info ? https://juejin.cn/post/6844903943516979213
# how to preserve all deadlock logs https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_print_all_deadlocks
# if not set, view latest deadlock log

require 'active_record'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 1, name: 'aaa', age: 10)
  Teacher.create(id: 5, name: 'bbb', age: 12)
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.where(id: 1).update(age: 15)

    sleep 3.seconds

    Teacher.where(id: 5).update(age: 10)
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.where(id: 5).update(age: 16)

    sleep 3.seconds

    Teacher.where(id: 1).update(age: 6)
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)