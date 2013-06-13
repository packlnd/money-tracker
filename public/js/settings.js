function create_category(form) {
  var content = '<span class="temp_label" style="background-color:#' + form.elements["color"].value + ';">' + form.elements["name"].value.toUpperCase() + '</span>';
  document.getElementById("templabel").innerHTML = content;
}

function save_category(form) {
  format_request("/settings/add/" + form.elements["name"].value.toUpperCase() + "/" + form.elements["color"].value, "setting_table");
}

function delete_category(id) {
  format_request("settings/" + id + "/delete", "setting_table");
}
