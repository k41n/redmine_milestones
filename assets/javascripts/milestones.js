function milestone_type_changed()
{
    selected = $('milestone_kind').value;
    if (selected == 'internal')
    {
        $('internal_milestone_form_part').show();
        $('aggregate_milestone_form_part').hide();
    }
    else
    {
        $('internal_milestone_form_part').hide();
        $('aggregate_milestone_form_part').show();
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

function add_children_milestone_fields(link, association, content)
{
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_"+association, "g");
    $('aggregate_milestone_form_part').insert({bottom: content.replace(regexp, new_id)});
}

function add_parent_milestone_fields(link, association, content)
{
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_"+association, "g");
    $('internal_milestone_form_part').insert({bottom: content.replace(regexp, new_id)});
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

function move_selected_to_assigned()
{
    move('available_projects', 'milestone_assigned_projects');
}

function move_selected_milestone_to_assigned()
{
    move('available_milestones', 'milestone_assigned_milestones');
}

function move_assigned_to_selected()
{
    move('milestone_assigned_projects', 'available_projects');
}

function move_assigned_milestone_to_selected()
{
    move('milestone_assigned_milestones', 'available_milestones');
}

function move(to, from)
{
    var selected = $(from);
    var pool = $(to);
    while (pool.selectedIndex != -1)
    {
        selected.appendChild(pool.options.item(pool.selectedIndex))
    }
}

function select_assigned()
{
    var assigned = $('milestone_assigned_projects');
    for (x = 0; x < assigned.options.length; x++)
    {
        assigned.options[x].selected = true;
    }
    var assigned = $('milestone_assigned_milestones');
    for (x = 0; x < assigned.options.length; x++)
    {
        assigned.options[x].selected = true;
    }
    return true;
}

function start_date_changed(confirmation, old_val)
{
    var new_val = $('milestone_start_date').value;
    if (new_val != undefined && new_val != old_val)
    {
        if (!confirm(confirmation))
        {
            $('milestone_start_date').value = old_val;
        }
    }
    return true;
}

function confirm_start_date_change(confirmation, old_val)
{
    Event.observe('milestone_start_date', 'change', function(event){
      start_date_changed(confirmation, old_val);
    });
}

function planned_date_changed(confirmation, old_val)
{
    var new_val = $('milestone_planned_end_date').value;
    if (new_val != undefined && new_val != old_val)
    {
        if (!confirm(confirmation))
        {
            $('milestone_planned_end_date').value = old_val;
        }
    }
    return true;
}

function confirm_planned_end_date_change(confirmation, old_val)
{
    Event.observe('milestone_planned_end_date', 'change', function(event){
        planned_date_changed(confirmation, old_val);
    });
}

function draw_chart(data, title)
{
    console.log("Drawing chart");
    console.log(data['percentage']);
    console.log(data['legend']);
    console.log(data['href']);
    window.data = data;
    window.percentage = data['percentage'];
    var r = Raphael("chart"),
        pie = r.piechart(320, 240, 100, data['percentage'], { legend: data['legend'], legendpos: "west", href: data['href']});

    r.text(320, 100, title).attr({ font: "20px sans-serif" });
    pie.hover(function () {
        this.sector.stop();
        this.sector.scale(1.1, 1.1, this.cx, this.cy);

        if (this.label) {
            this.label[0].stop();
            this.label[0].attr({ r: 7.5 });
            this.label[1].attr({ "font-weight": 800 });
        }
    }, function () {
        this.sector.animate({ transform: 's1 1 ' + this.cx + ' ' + this.cy }, 500, "bounce");

        if (this.label) {
            this.label[0].animate({ r: 5 }, 500, "bounce");
            this.label[1].attr({ "font-weight": 400 });
        }
    });}