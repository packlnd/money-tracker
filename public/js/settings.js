$(".save").click(function() {
  handle_category("add", "setting_table");
});

$(".format").keyup(function() {
  handle_category("format", "templabel");
});

$(".delete").click(function() {
  var id = $(this).attr("id");
  format_request("settings/" + id + "/delete", "setting_table");
});

function handle_category(command, div) {
  var color = $("#color").attr("value"),
    name = $("#name").attr("value").toUpperCase();
  if (name == "") {
    return;
  }
  var url = "/settings/" + command + "/" + name + "/" + color;
  format_request(url, div);
}
