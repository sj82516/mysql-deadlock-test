require 'active_record'

database = 'test'
config = { adapter: 'mysql2',
         host: '127.0.0.1',
         username: 'root',
         password: 'root',
         port: 3310,
         database: database }
ActiveRecord::Base.establish_connection(
  config
)

ActiveRecord::Base.connection.drop_database(database)
ActiveRecord::Base.connection.create_database(database)
ActiveRecord::Base.establish_connection(
  config
)
ActiveRecord::ConnectionAdapters::MySQL::TableDefinition

ActiveRecord::Base.connection.create_table("teachers", id: false) do |t|
  t.primary_key :id
  t.string :name
  t.index :name, unique: true
  t.integer :age, index: true
  t.string :note
end

ActiveRecord::Base.logger = Logger.new(STDOUT)
