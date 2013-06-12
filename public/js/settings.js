function create_category(form) {
  var content = '<span class="cat_label" style="height:120%; background-color:#' + form.elements["color"].value + ';"><input type="checkbox"/>' + form.elements["name"].value + '\r\n</span>';
  document.getElementById("templabel").innerHTML = content;
}

function save_category(form) {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      document.getElementById("setting_table").innerHTML = xmlhttp.responseText;
    }
  }
  xmlhttp.open("GET", "/settings/add/" + form.elements["name"].value + "/" + form.elements["color"].value, true);
  xmlhttp.send();
}
