# prove: lock by index order
# only work for MySQL 8.0+ because it could create index by column order
# before 8.0, all index are asc.
# https://dev.mysql.com/doc/refman/5.7/en/create-index.html
# A key_part specification can end with ASC or DESC. These keywords are permitted for future extensions for specifying ascending or descending index value storage. Currently, they are parsed but ignored; index values are always stored in ascending order.

require 'active_record'

require './utils/parallel_transaction'

def init
  Teacher.create(id: 2, name: 'a', age: 10)
  Teacher.create(id: 5, name: 'b', age: 12)

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