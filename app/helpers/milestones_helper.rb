module MilestonesHelper
  def format_version_sharing(sharing)
    sharing = 'none' unless Milestone::MILESTONE_SHARINGS.include?(sharing)
    l("label_milestone_sharing_#{sharing}")
  end

  STATUS_BY_CRITERIAS = %w(category tracker status priority author assigned_to)

  def render_issue_status_by(milestone, criteria)
    criteria = 'category' unless STATUS_BY_CRITERIAS.include?(criteria)

    h = Hash.new {|k,v| k[v] = [0, 0]}
    begin
      # Total issue count
      Issue.count(:group => criteria,
                  :conditions => ["#{Issue.table_name}.milestone_id = ?", milestone.id]).each {|c,s| h[c][0] = s}
      # Open issues count
      Issue.count(:group => criteria,
                  :include => :status,
                  :conditions => ["#{Issue.table_name}.milestone_id = ? AND #{IssueStatus.table_name}.is_closed = ?", milestone.id, false]).each {|c,s| h[c][1] = s}
    rescue ActiveRecord::RecordNotFound
      # When grouping by an association, Rails throws this exception if there's no result (bug)
    end
    counts = h.keys.compact.sort.collect {|k| {:group => k, :total => h[k][0], :open => h[k][1], :closed => (h[k][0] - h[k][1])}}
    max = counts.collect {|c| c[:total]}.max

    render :partial => 'issue_counts', :locals => {:milestone => milestone, :criteria => criteria, :counts => counts, :max => max}
  end

  def status_by_options_for_select(value)
    options_for_select(STATUS_BY_CRITERIAS.collect {|criteria| [l("field_#{criteria}".to_sym), criteria]}, value)
  end

  # http://railscasts.com/episodes/197-nested-model-form-part-2?view=asciicast
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f=>builder)
    end
    link_to_function(name, h("add_fields(this,\"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def link_to_add_children_milestone_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f=>builder)
    end
    link_to_function(name, h("add_children_milestone_fields(this,\"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def link_to_add_parent_milestone_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f=>builder)
    end
    link_to_function(name, h("add_parent_milestone_fields(this,\"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def milestone_name_from_pov_of(project, milestone)
    if milestone.project_id == project.id
      if milestone.aggregate?
        milestone.name
      else
        "#{milestone.version.name}/#{milestone.name}"
      end
    else
      if milestone.aggregate?
        "#{milestone.project.name}/#{milestone.name}"
      else
        "#{milestone.project.name}/#{milestone.version.name}/#{milestone.name}"
      end

    end
  end

end
