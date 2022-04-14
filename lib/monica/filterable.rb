module Monica
  module Filterable
    extend ActiveSupport::Concern

    included do
      columns.each do |column|
        scope "filter_by_#{column.name}".to_sym, -> (filter){
          where(column.name.to_sym => filter)
        }
      end
    end
  end
end
