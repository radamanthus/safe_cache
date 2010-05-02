require 'rubygems'
require 'active_support'
require 'active_support/test_case'

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'
require 'action_view/test_case'

ActiveRecord::Schema.verbose = false
 
begin
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
rescue ArgumentError
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
end

ActiveRecord::Base.connection.create_table(:authors) do |t|
  t.string      :first_name
  t.string      :last_name
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:books) do |t|
  t.string      :title
  t.string      :isbn
  t.integer     :page_count
  t.references  :author
  t.timestamps
end

require File.dirname(__FILE__) + '/libs/book'
require File.dirname(__FILE__) + '/libs/author'
