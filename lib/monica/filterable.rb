require_relative 'helpers'

module Monica
  module Filterable

    def self.included(base)
      base.extend ClassMethods
      base.extend Monica::Helpers
      base.singleton_class.class_eval do
        base.auto_filter_columns.each do |column|
          next if respond_to? "filter_by_#{column}".to_sym

          define_method("filter_by_#{column}") do |filter|
            if filter.is_a? Hash
              results = self
              filter.each do |key, value|
                results = results.query column, key.to_s, value
              end
              results
            else
              where(column.to_sym => filter)
            end
          end
        end
      end
    end

    module ClassMethods
      def filter(params)
        return and_filter(params) if params.is_a? Hash
        return or_filter(params) if params.is_a? Array
      end

      def and_filter(params)
        results = self
        params.each do |key, value|
          results = results.send("filter_by_#{key}", value) if value.present?
        end
        results
      end

      def or_filter(params)
        results = and_filter(params.first)
        other_filters = params.drop(1)

        return results if other_filters.empty?

        other_filters.each do |new_filter|
          results = results.or(and_filter(new_filter))
        end
        results
      end

      def auto_filter_columns
        column_names - SKIP_COLUMNS
      end

      def filter_columns
        methods.map do |method|
          if method.to_s.include? 'filter_by_'
            method.to_s.tap{ |s| s.slice!('filter_by_') }
          end
        end.compact!
      end
      

      SKIP_COLUMNS = %w[
        id
      ].freeze
    end

    module ControllerMethods

      def filter_params
        !simple_filter_params.empty? ? simple_filter_params : complex_filter_params
      end
      

      def simple_filter_params
        filter = controller_name.classify.constantize.filter_columns.map do |column|
          [
            [column.to_sym],
            [column.to_sym => []],
            [column.to_sym => [:gte, :lte, :gt, :lt, :eq, :neq, :like, :nlike, :n, :nn, btw:[], nbtw: []]]
          ]
        end.flatten
  
        params.permit(*filter).to_hash
      end

      def complex_filter_params
        filter = controller_name.classify.constantize.filter_columns.map do |column|
          [
            [column.to_sym],
            [column.to_sym => []],
            [column.to_sym => [:gte, :lte, :gt, :lt, :eq, :neq, :like, :nlike, :n, :nn, btw:[], nbtw: []]]
          ]
        end.flatten

        params.require(:filter).map do |p|
          p.permit(*filter)
        end.map(&:to_hash)
      end
    end

    def query_mapper(match)
      MATCHERS[match] || '='
    end

    private

    MATCHERS = {
      'eq'    => '=',
      'neq'   => '!=',
      'gt'    => '>',
      'lt'    => '<',
      'gte'   => '>=',
      'lte'   => '<=',
      'like'  => 'LIKE',
      'nlike' => 'NOT LIKE',
      'btw'   => 'BETWEEN',
      'nbtw'  => 'NOT BETWEEN',
      'n'     => 'IS NULL',
      'nn'    => 'IS NOT NULL'
    }

    def query(column, key, value)
      operator = MATCHERS[key] || '='

      case operator
      when 'LIKE', 'NOT LIKE'
        where("UPPER(#{column}) #{operator} UPPER('%#{value}%')")
      when 'BETWEEN', 'NOT BETWEEN'
        where("#{column} #{operator} '#{value[0]}' AND '#{value[1]}'")
      when 'IS NULL', 'IS NOT NULL'
        where("#{column} #{operator}")
      else
        where("UPPER(#{column}) #{operator} UPPER('#{value}')")
      end
    end
  end
end
