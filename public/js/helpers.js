$("a.showhide").click(function() {
  var id_show = $(this).attr("href");
  $(id_show).slideToggle();
  return false;
});

function format_categories() {
  var s = "",
    i = 2,
    element = $("#cat" + i);
  while ($(element).attr("type") == 'checkbox') {
    if ($(element).is(":checked")) {
      s += "." + i;
    }
    element = $("#cat" + ++i);
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
