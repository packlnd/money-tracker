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
  $.ajax({
    url : "history/" + $(this).attr("id") + "/siblings/",
    success : function(ids) {
      for (id in ids) {
        format_request("history/" + id + "/increment", "#cat_" + id);
      }
    }
  });
});

$("a.edit").click(function() {
  var id = $(this).attr("id");
  format_request("history/" + id + "/edit", "#row" + id);
});

//http://jsfiddle.net/qY9UM/2/
$("a.save").bind("click", function() {
  alert("hello");
  var id = $(this).attr("id"),
    name = $("#edit_text").attr("value");
  format_request("history/" + id + "/" + name + "/save", "#row" + id);
});

