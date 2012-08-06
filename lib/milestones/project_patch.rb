module ProjectPatch
  def self.included(base) # :nodoc:

    base.class_eval do
      has_many :milestones, :class_name=>'Milestone', :foreign_key => :project_id

      has_many :milestone_project_assignments
      has_many :assigned_milestones, :through => :milestone_project_assignments, :source => :milestone

      def self.unassigned_with(milestone)
        Project.all - milestone.projects
      end

    end

    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def shared_milestones
      if new_record?
        Milestone.scoped(:include => :project,
                         :conditions => "#{Project.table_name}.status = #{Project::STATUS_ACTIVE} AND #{Milestone.table_name}.sharing = 'system'")
      else
        r = root? ? self : root
        Milestone.scoped(:include => [:project],
                         :conditions => "#{Project.table_name}.id = #{id}" +
                             " OR (#{Project.table_name}.status = #{Project::STATUS_ACTIVE} AND (" +
                             " #{Milestone.table_name}.sharing = 'system'" +
                             " OR (#{Project.table_name}.lft >= #{r.lft} AND #{Project.table_name}.rgt <= #{r.rgt} AND #{Milestone.table_name}.sharing = 'tree')" +
                             " OR (#{Project.table_name}.lft < #{lft} AND #{Project.table_name}.rgt > #{rgt} AND #{Milestone.table_name}.sharing IN ('hierarchy', 'descendants'))" +
                             " OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt} AND #{Milestone.table_name}.sharing = 'hierarchy')" +
                             " OR (#{Milestone.table_name}.project_id = '#{self.id}')" +
                             "))")
      end
    end

    def all_milestones(omit_subprojects = true)
      if omit_subprojects
        (shared_milestones + assigned_milestones).uniq
      else
        (shared_milestones + assigned_milestones + descendants.active.collect{|x| x.all_milestones}.flatten).uniq
      end
    end
  end

end