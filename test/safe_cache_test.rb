require File.dirname(__FILE__) + '/test_helper.rb'

class SafeCacheTest < Test::Unit::TestCase
  context "an ActiveRecord model" do
    setup do
      @author = Author.create(:first_name => "J.R.R", :last_name => "Tolkien")
      @book = Book.create(:author => @author, :title => "The Silmarillion")
      # HOW DO WE START THE CACHE SERVER?
      # Should we include in this plugin rake tasks to start memcached, MongoDB, etc?
    end
    
    teardown do
      @book.destroy
      @author.destroy
    end
    
    should "store data to cache and retrieve it correctly" do
      uncached_author = Author.first
      cached_author = Author.cache_safely(:first)
      assert cached_author.eql?(uncached_author)
    end
    
    should "retrieve from database even if cache is empty" do
      first_book = Book.first
      Book.cache_safely(:first)
      Rails.cache.clear
      book_retrieved_from_cache = Book.cache_safely(:first)
      assert !book_retrieved_from_cache.nil?
      assert first_book.eql?(book_retrieved_from_cache)
    end
    
    should "retrieve from database even if cache access results in an error" do
      first_book = Book.first
      Book.cache_safely(:first)
      system("killall memcached")
      book_retrieved_from_cache = Book.cache_safely(:first)
      assert !book_retrieved_from_cache.nil?
      assert first_book.eql?(book_retrieved_from_cache)
    end
  end
end
