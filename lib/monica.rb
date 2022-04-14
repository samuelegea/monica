# frozen_string_literal: true

require_relative "monica/version"
require_relative "monica/filterable"
require_relative "monica/sortable"
require_relative "monica/searchable"
require_relative "monica/paginatable"

module Monica
  class Error < StandardError; end
  # Your code goes here...

  def method_name
    
    end
    
end

ActiveSupport.on_load(:active_record) do
  class ActiveRecord::Base
    
    # Define the methods to use in the helpers
    
    def self.act_as_filterable(options={})
      if included_modules.include?(Monica::Filterable)
        puts "[WARN] #{self.name} is calling act_as_filterable more than once!"
  
        return
      end
      include Monica::Filterable
    end
    
    def self.act_as_sortable(options={})
      if included_modules.include?(Monica::Sortable)
        puts "[WARN] #{self.name} is calling act_as_sortable more than once!"
  
        return
      end
      include Monica::Sortable
    end

    def self.act_as_paginatable(options={})
      if included_modules.include?(Monica::Paginatable)
        puts "[WARN] #{self.name} is calling act_as_paginatable more than once!"
  
        return
      end
      include Monica::Paginatable
    end
    
    def self.act_as_searchable(options={})
      if included_modules.include?(Monica::Searchable)
        puts "[WARN] #{self.name} is calling act_as_searchable more than once!"
  
        return
      end
      include Monica::Searchable
    end

  end
end
