$(".forms").hide();

$("input.text_filter").keyup(function(){filter_history()});
$("input.click_filter").click(function(){filter_history()});

function filter_history() {
  var from = $("#from").attr("value"),
    to = $("#to").attr("value"),
    categories = format_categories(),
    text = $("#query").attr("value");

    if (text == "") {
      format_request("/history/update/" + from + "/" + to + "/" + categories, "#historytable");
    } else {
      format_request("history/update/" + from + "/" + to + "/" + categories + "/" + text, "#historytable");
    }
}

$("a.delete").click(function() {
  var id = $(this).attr("id");
  $("#row" + id).hide();
  $.ajax({
    url: "/history/" + id + "/delete"});
});

$("a.category").click(function() {
  var id = $(this).attr("id");
  format_request("history/" + id + "/increment", "#cat_" + id);
});
