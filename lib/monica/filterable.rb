module Monica
  module Filterable
    
    self.class.columns.each do |column|
      scope "filter_by_#{column.name}".to_sym, -> (filter){
        where(column.name.to_sym => filter)
      }

      scope
    end
  end
end
