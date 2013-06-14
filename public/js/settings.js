function create_category(form) {
  handle_category(form, "format", "templabel");
}

function save_category(form) {
  handle_category(form, "add", "setting_table");
}

function handle_category(form, command, div) {
  var color = form.elements["color"].value,
    name = form.elements["name"].value.toUpperCase();
  if (name == "") {
    return;
  }
  var url = "/settings/" + command + "/" + name + "/" + color;
  format_request(url, div);
}

function delete_category(id) {
  format_request("settings/" + id + "/delete", "setting_table");
}
