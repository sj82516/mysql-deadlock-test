# basic: you hold what I wait for and I hold what you wait for
# how to analyze deadlock info ? https://juejin.cn/post/6844903943516979213

require 'active_record'

require './script'

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

script(init: init, t1: t1, t2: t2)