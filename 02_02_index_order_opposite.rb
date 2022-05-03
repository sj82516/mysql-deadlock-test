# if index lock in opposite order, deadlock could happen

require 'active_record'

require './utils/parallel_transaction'

def init
  teachers = ('a'..'zz').to_a.reverse.map { |l|  {name: l, age: 12} }
  Teacher.insert_all(teachers)
#  table look like (1, 'zz') , (2, 'zy') ..... name and id order is opposite
end

t1 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.first
    sleep 1.seconds
    Teacher.where('id > 1').order(:id).update_all(age: 10)
  end
end

t2 = Proc.new do
  ActiveRecord::Base.transaction(isolation: :repeatable_read) do
    Teacher.first
    sleep 1.seconds
    ActiveRecord::Base.connection.execute('update teachers use index (index_teachers_on_name) set note=10 where  name > "a" and name < "dd"')
  end
end

parallel_transaction(init: init, t1: t1, t2: t2)