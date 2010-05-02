class Author < ActiveRecord::Base
  caches_safely
  
  has_many :books
end