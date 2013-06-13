function format_categories(form, number_of_categories) {
  var s = "";
  for (var i = 1; i < number_of_categories+1; i++) {
    var element = form.elements["category[" + i + "]"];
    if (element != undefined && element.checked) {
      s += "." + i;
    }
  }
  return s.substring(1);
}

function format_request(url, div) {
  handle_request(url, div, function(response) {
    document.getElementById(div).innerHTML = response;
  });
}

function handle_request(url, div, func) {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      func(xmlhttp.responseText);
    }
  }
  xmlhttp.open("GET", url, true);
  xmlhttp.send();
}
