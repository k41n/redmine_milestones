require_dependency 'query'

module Milestones
  module QueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        # alias_method :statement_original_contacts, :statement
        # alias_method :statement, :statement_contacts

        alias_method :available_filters_original_milestone, :available_filters
        alias_method :available_filters, :available_filters_milestone

        base.add_available_column(QueryColumn.new(:milestone))

      end
    end


    module InstanceMethods
      def sql_for_milestone_field(field, operator, value)
        compare = operator == '=' ? 'IN' : 'NOT IN'
        milestones_select = "(#{value.join(',')})"

        "(#{Issue.table_name}.milestone_id #{compare} (#{milestones_select}))"
      end

      def available_filters_milestone
        # && !RedmineContacts.settings[:issues_filters]
        if @available_filters.blank? && (project.blank? || project.module_enabled?(:milestones_module))
          select_fields = "#{Milestone.table_name}.name, #{Milestone.table_name}.id"
          available_filters_original_milestone.merge!({ 'milestone' => {
              :type   => :list,
              :order  => 6,
              :values => project.milestones.find(:all, :select => select_fields, :limit => 500).collect{ |t| [t.name, t.id.to_s] }.uniq
            }}) if !available_filters_original_milestone.key?("milestone") && (project.blank? || User.current.allowed_to?(:view_milestones, project))
        else
          available_filters_original_milestone
        end
        @available_filters
      end
    end
  end
end
