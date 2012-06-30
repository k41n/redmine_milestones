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
    selected = $('milestone_project').value;
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
    selected = $('milestone_subproject').value;
    if (selected == '0')
    {
        selected = $('milestone_project').value;
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