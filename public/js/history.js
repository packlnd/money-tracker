xmlhttp = new XMLHttpRequest();

function display_history(form, number_of_categories) {
  xmlhttp.onreadystatechange = function() {
    if(xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      document.getElementById("historytable").innerHTML = xmlhttp.responseText;
    } else {
      document.getElementById("historytable").innerHTML = "Laddar...";
    }
  }
  var from = form.elements["date_from"].value;
  var to = form.elements["date_to"].value;
  var categories = format_categories(form, number_of_categories)
  var url = "/history/update/" + from + "/" + to + "/" + categories;
  xmlhttp.open("GET", url, true);
  xmlhttp.send();
}
