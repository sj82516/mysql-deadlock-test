require 'active_record'

require './connection'

ActiveRecord::Base.transaction(isolation: :repeatable_read) do

end