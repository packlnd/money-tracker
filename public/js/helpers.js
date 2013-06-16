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
  handle_request(url, function(response) {
    $(div).html(response);
  });
}

function handle_request(request_url, func) {
  $.ajax({
    url: request_url,
    success: function(data){func(data);}});
}
