function display_history(form, number_of_categories) {
  var from = form.elements["date_from"].value,
    to = form.elements["date_to"].value,
    categories = format_categories(form, number_of_categories),
    text = form.elements["search"].value;
  if (text == "") {
    format_request("/history/update/" + from + "/" + to + "/" + categories, "historytable");
  } else {
    format_request("/history/update/" + from + "/" + to + "/" + categories + "/" + text, "historytable");
  }
}

function delete_transaction(id) {
  document.getElementById("r" + id).innerHTML = "";
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", "/history/" + id + "/delete", true);
  xmlhttp.send();
}

function increment_category(id) {
  format_request("history/" + id + "/increment", "cat_" + id);
}
