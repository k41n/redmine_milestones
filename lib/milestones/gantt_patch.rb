module GanttPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      def render(options={})
        options = {:top => 0, :top_increment => 20, :indent_increment => 20, :render => :subject, :format => :html}.merge(options)
        indent = options[:indent] || 4

        @subjects = '' unless options[:only] == :lines
        @lines = '' unless options[:only] == :subjects
        @number_of_rows = 0

        Project.project_tree(projects) do |project, level|
          options[:indent] = indent + level * options[:indent_increment]
          render_project(project, options)
          break if abort?
        end

        @subjects_rendered = true unless options[:only] == :lines
        @lines_rendered = true unless options[:only] == :subjects

        render_end(options)
      end

      def render_project(project, options={})
        subject_for_project(project, options) unless options[:only] == :lines
        line_for_project(project, options) unless options[:only] == :subjects

        options[:top] += options[:top_increment]
        options[:indent] += options[:indent_increment]
        @number_of_rows += 1
        return if abort?

        issues = project_issues(project).select {|i| i.fixed_version.nil?}
        sort_issues!(issues)
        if issues
          render_issues(issues, options)
          return if abort?
        end

        versions = project_versions(project)
        versions.each do |version|
          render_version(project, version, options)
        end
        if project.module_enabled?(:milestones_module)
          milestones = project.milestones.versionless
          milestones.each do |milestone|
            render_milestone(project, milestone, options)
          end
        end
        # Remove indent to hit the next sibling
        options[:indent] -= options[:indent_increment]
      end

      def render_version(project, version, options={})
        # Version header
        subject_for_version(version, options) unless options[:only] == :lines
        line_for_version(version, options) unless options[:only] == :subjects

        options[:top] += options[:top_increment]
        @number_of_rows += 1
        return if abort?

        issues = version_issues(project, version).select{|x| x.milestone.nil?}
        if issues
          sort_issues!(issues)
          # Indent issues
          options[:indent] += options[:indent_increment]
          render_issues(issues, options)
          options[:indent] -= options[:indent_increment]
        end
        options[:indent] += options[:indent_increment]
        if project.module_enabled?(:milestones_module)
          milestones = version.milestones
          milestones.each do |milestone|
            render_milestone(project, milestone, options)
          end
        end
        options[:indent] -= options[:indent_increment]
      end


      def render_milestone(project, milestone, options={})
        # Version header
        subject_for_milestone(milestone, options) unless options[:only] == :lines
        line_for_milestone(milestone, options) unless options[:only] == :subjects

        options[:top] += options[:top_increment]
        @number_of_rows += 1
        return if abort?

        issues = milestone.issues
        if issues
          sort_issues!(issues)
          # Indent issues
          options[:indent] += options[:indent_increment]
          render_issues(issues, options)
          options[:indent] -= options[:indent_increment]
        end
      end

      def subject_for_milestone(milestone, options)
        case options[:format]
          when :html
            subject = "<span class='icon icon-milestone'>".html_safe
            subject << view.link_to_milestone(milestone).html_safe
            subject << '</span>'.html_safe
            html_subject(options, subject, :css => "version-name")
          when :image
            image_subject(options, milestone.name)
          when :pdf
            pdf_new_page?(options)
            pdf_subject(options, milestone.name)
        end
      end

      def line_for_milestone(milestone, options)
        # Skip versions that don't have a start_date
        if milestone.is_a?(Milestone) && milestone.start_date && milestone.planned_end_date
          options[:zoom] ||= 1
          options[:g_width] ||= (self.date_to - self.date_from + 1) * options[:zoom]

          coords = coordinates(milestone.start_date, milestone.planned_end_date, milestone.completed_pourcent, options[:zoom])
          label = "#{h milestone.name } #{h milestone.completed_pourcent.to_i.to_s}%"
          label = h("#{milestone.project} -") + label unless @project && @project == milestone.project

          case options[:format]
            when :html
              html_task(options, coords, :css => "version task", :label => label, :markers => true)
            when :image
              image_task(options, coords, :label => label, :markers => true, :height => 3)
            when :pdf
              pdf_task(options, coords, :label => label, :markers => true, :height => 0.8)
          end
        else
          ActiveRecord::Base.logger.debug "Gantt#line_for_version was not given a version with a start_date"
          ''
        end
      end

    end

  end
end