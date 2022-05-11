module Monica
  module Helpers
    def controller_name
      # Override this if you want
      (controller_namespace.empty? ? '' : controller_namespace.concat('::')).concat(self.to_s.pluralize, 'Controller')
    end

    def controller_namespace
      # Override this if you use something like API::V1::PostsController
      ''
    end

    def query_mapper(match)
      MATCHERS[match] || '='
    end
  end
end
