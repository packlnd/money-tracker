var MOUSE_DOWN, $slider, min_pos, max_pos;

$(document).ready(function() {
  min_pos = $(".red").offset().left;
  $(".slider").offset({left:min_pos});
});

$(".save").click(function() {
  handle_category("add", "#setting_table");
});

$(".format").input(function() {
  handle_category("format", "#templabel");
});

$(document).on("click", "a.delete", function() {
  var id = $(this).attr("id");
  $("#row" + id).hide();
  $.ajax({
  url: "/settings/" + id + "/delete"});
});

$(document).on("click", "a.edit", function() {

});

$(".red, .green, .blue").click(function(e) {
  var curr_pos = e.pageX;
  min_pos = $(this).offset().left;
  max_pos = min_pos + $(this).width();
  if (curr_pos >= min_pos && curr_pos < max_pos) {
    $(".slider#" + $(this).attr("class")).offset({left:curr_pos});
  }
  handle_category("format", "#templabel");
});

$(".slider").mousedown(function(e) {
  MOUSE_DOWN = true;
  $slider = $(this);
});

function read_color(color) {
  return parseInt($(".slider#" + color).offset().left) - min_pos;
}

function to_hex(n) {
  var h = n.toString("16");
  if(h.length == 1) {
    return "0" + h;
  }
  return h
}

function hex_color() {
    var r = read_color("red"),
      g = read_color("green"),
      b = read_color("blue");
  return to_hex(r) + to_hex(g) + to_hex(b);
}

$(document).mousemove(function(e) {
  if (!MOUSE_DOWN || !$slider) {
    return;
  }
  var curr_pos = e.pageX;
  if (curr_pos >= min_pos && curr_pos < max_pos) {
    $slider.offset({left:curr_pos});
  }
});

$(document).mouseup(function(e) {
  $slider = undefined;
  MOUSE_DOWN = false;
  handle_category("format", "#templabel");
});

function handle_category(command, div) {
  var name = $("#name").val().toUpperCase();
  if (name == "") {
    return;
  }
  var url = "/settings/" + command + "/" + name + "/" + hex_color();
  format_request(url, div);
}
