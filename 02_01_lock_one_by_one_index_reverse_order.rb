# update multi record, innoDb would lock record one by one
# https://dev.mysql.com/doc/refman/5.7/en/update.html
# If an UPDATE statement includes an ORDER BY clause, the rows are updated in the order specified by the clause. This can be useful in certain situations that might otherwise result in an error. Suppose that a table t contains a column id that has a unique index. The following statement could fail with a duplicate-key error, depending on the order in which rows are updated:

require 'active_record'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 2, name: 'aaa', age: 10)
  Teacher.create(id: 5, name: 'bbb', age: 12)

  ActiveRecord::Base.connection.execute('create unique index id_desc on teachers (id DESC)')
  ActiveRecord::Base.connection.execute('create unique index id_asc on teachers (id ASC)')
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 1.seconds
    ActiveRecord::Base.connection.execute('update teachers use index (id_desc) set age=5 where id > 1')
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    sleep 1.seconds
    ActiveRecord::Base.connection.execute('update teachers use index (id_asc) set age=5 where id > 1')
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)