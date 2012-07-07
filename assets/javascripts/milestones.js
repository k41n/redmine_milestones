function milestone_type_changed()
{
    selected = $('milestone_kind').value;
    if (selected == 'internal')
    {
        $('internal_milestone_form_part').show();
    }
    else
    {
        $('internal_milestone_form_part').hide();
    }
}

function new_milestone_project_selected()
{
    selected = $('milestone_project_id').value;
    new Ajax.Request('/milestones/parent_project_changed/?id='+selected,
        {
            method:'get',
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function new_milestone_subproject_selected()
{
    selected = $('milestone_subproject_id').value;
    if (selected == '0')
    {
        selected = $('milestone_project_id').value;
    }
    new Ajax.Request('/milestones/subproject_changed/?id='+selected,
        {
            method:'get',
            onSuccess: function(transport){
                var response = transport.responseText || "";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function planned_end_date_radio_changed()
{
    if (!$('milestone_fixed_planned_end_date_true').checked)
    {
        $('milestone_planned_end_date').disable();
        $('milestone_planned_end_date_trigger').hide();
        $('milestone_previous_planned_end_date_milestone_id').enable();
        $('milestone_planned_end_date_offset').enable();
        // Chrome bug workaround. In chrome link cannot reappear if simply hidden/shown twice
        $('recalculate_planned_end_date').appear({duration: 0.2});
    }
    else
    {
        $('milestone_planned_end_date').enable();
        $('milestone_planned_end_date_trigger').show();
        $('milestone_previous_planned_end_date_milestone_id').disable();
        $('milestone_planned_end_date_offset').disable();
        $('recalculate_planned_end_date').hide();
    }
}

function start_date_radio_changed()
{
    if (!$('milestone_fixed_start_date_true').checked)
    {
        $('milestone_start_date').disable();
        $('milestone_start_date_trigger').hide();
        $('milestone_previous_start_date_milestone_id').enable();
        $('milestone_start_date_offset').enable();
        // Chrome bug workaround. In chrome link cannot reappear if simply hidden/shown twice
        $('recalculate_start_date').appear({duration: 0.2});
    }
    else
    {
        $('milestone_start_date').enable();
        $('milestone_start_date_trigger').show();
        $('milestone_previous_start_date_milestone_id').disable();
        $('milestone_start_date_offset').disable();
        $('recalculate_start_date').hide();
    }
}

function recalculate_start_date()
{
    from_milestone = $('milestone_previous_start_date_milestone_id').value;
    offset = $('milestone_start_date_offset').value;
    new Ajax.Request('/milestones/recalculate_start_date',
        {
            method:'post',
            parameters: {
                from: from_milestone,
                offset: offset
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function recalculate_planned_end_date()
{
    from_milestone = $('milestone_previous_planned_end_date_milestone_id').value;
    offset = $('milestone_planned_end_date_offset').value;
    new Ajax.Request('/milestones/recalculate_planned_end_date',
        {
            method:'post',
            parameters: {
                from: from_milestone,
                offset: offset
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function recalculate_actual_date(id)
{
    new Ajax.Request('/milestones/recalculate_actual_date',
        {
            method:'get',
            parameters: {id: id},
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function issue_version_changed(project)
{
    val = $('issue_fixed_version_id').value;
    new Ajax.Request('/milestones/issue_version_changed',
        {
            method:'get',
            parameters: {id: val, project_id: project},
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function milestone_version_changed(project)
{
    val = $('milestone_version_id').value;
    new Ajax.Request('/milestones/milestone_version_changed',
        {
            method:'get',
            parameters: {id:val, project_id: project},
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                eval(response);
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
}

function milestone_sharing_changed(project)
{
    val = $('milestone_sharing').value;
    if (val == "specific")
    {
        $('assigned_projects_placeholder').show();
    }
    else
    {
        $('assigned_projects_placeholder').hide();
    }
}

function add_fields(link, association, content)
{
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_"+association, "g");
    $('assigned_projects_placeholder').insert({bottom: content.replace(regexp, new_id)});
}

function remove_fields(link)
{
    $(link).previous("input[type=hidden]").value = "1";
    $(link).up(".fields").hide();
}

function show_milestones_changed()
{
    var val = $('show_milestones').checked;
    console.log(val);
    if (val == '1')
    {
        $('hide_milestones').value = '0';
    }
    else
    {
        $('hide_milestones').value = '1';
    }
}

function show_hidden_milestones_changed()
{
    var val = $('show_completed_milestones').checked;
    console.log(val);
    if (val == '1')
    {
        $('hide_completed_milestones').value = '0';
    }
    else
    {
        $('hide_completed_milestones').value = '1';
    }
}