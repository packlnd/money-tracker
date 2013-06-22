$("#to").datepicker({
  dateFormat: "yy-mm-dd",
  onClose: function(date){filter_history()}
});

$("#from").datepicker({
  dateFormat: "yy-mm-dd",
  onClose: function(date){filter_history()}
});

$(".forms").hide();

$("input.text_filter").keyup(function(){filter_history()});
$("input.click_filter").click(function(){filter_history()});

function filter_history() {
  var from = $("#from").val(),
    to = $("#to").val(),
    categories = format_categories(),
    text = $("#query").val();

  if (text == "") {
    format_request("/history/update/" + from + "/" + to + "/" + categories, "#historytable");
  } else {
    format_request("history/update/" + from + "/" + to + "/" + categories + "/" + text, "#historytable");
  }
}

$(document).on("click", "a.delete", function() {
  var id = $(this).attr("id");
  $("#row" + id).hide();
  $.ajax({
    url: "/history/" + id + "/delete"});
});

$(document).on("click", "a.category", function() {
  var id = $(this).attr("id");
  format_request("history/" + id + "/increment", "#cat_" + id);
});

$(document).on("click", "a.edit", function() {
  var id = $(this).attr("id");
  format_request("history/" + id + "/edit", "#row" + id);
});

$(document).on("click", "a.save", function() {
  var id = $(this).attr("id"),
    name = $("input#edit_text.smaller").val();
  format_request("history/" + id + "/" + name + "/save", "#row" + id);
});
