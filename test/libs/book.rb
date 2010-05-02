class Book < ActiveRecord::Base
  caches_safely
  
  belongs_to :author
end