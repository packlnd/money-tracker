$(".forms").hide();
$("a.showhide").click(function() {
  var id_show = $(this).attr("href");
  $(id_show).slideToggle();
  return false;
});

$("a.delete").click(function() {
  var id = $(this).attr("id");
  $("#row" + id).hide();
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", "/history/" + id + "/delete", true);
  xmlhttp.send();
});

function display_history(form) {
  var from = form.elements["date_from"].value,
    to = form.elements["date_to"].value,
    categories = format_categories(),
    text = form.elements["search"].value;
  if (text == "") {
    format_request("/history/update/" + from + "/" + to + "/" + categories, "historytable");
  } else {
    format_request("/history/update/" + from + "/" + to + "/" + categories + "/" + text, "historytable");
  }
}

function increment_category(id) {
  format_request("history/" + id + "/increment", "cat_" + id);
}
