function create_category(form) {
  var content = '<span class="temp_label" style="background-color:#' + form.elements["color"].value + ';">' + form.elements["name"].value.toUpperCase() + '</span>';
  document.getElementById("templabel").innerHTML = content;
}

function save_category(form) {
  handle_request("/settings/add/" + form.elements["name"].value.toUpperCase() + "/" + form.elements["color"].value, "setting_table");
}

function delete_category(id) {
  handle_request("settings/" + id + "/delete", "setting_table");
}

function handle_request(url, div) {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      document.getElementById(div).innerHTML = xmlhttp.responseText;
    }
  }
  xmlhttp.open("GET", url, true);
  xmlhttp.send();
}
