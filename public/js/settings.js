function create_category(form) {
  var color = form.elements["color"].value,
    name = form.elements["name"].value.toUpperCase();
  format_request("/settings/format/" + name + "/" + color, "templabel");
}

function save_category(form) {
  format_request("/settings/add/" + form.elements["name"].value.toUpperCase() + "/" + form.elements["color"].value, "setting_table");
}

function delete_category(id) {
  format_request("settings/" + id + "/delete", "setting_table");
}
