var min_pos = 552,
  max_pos = 808,
  MOUSE_DOWN,
  $slider;

$(document).ready(function() {
  $(".slider#red").offset({left:min_pos});
  $(".slider#green").offset({left:min_pos});
  $(".slider#blue").offset({left:min_pos});
});

$(".save").click(function() {
  handle_category("add", "#setting_table");
});

$(".format").keyup(function() {
  handle_category("format", "#templabel");
});

$(".delete").click(function() {
  var id = $(this).attr("id");
  format_request("settings/" + id + "/delete", "#setting_table");
});

$(".red, .green, .blue").click(function(e) {
  $(".slider#" + $(this).attr("class")).offset({left:e.pageX});
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
  var name = $("#name").attr("value").toUpperCase();
  if (name == "") {
    return;
  }
  var url = "/settings/" + command + "/" + name + "/" + hex_color();
  format_request(url, div);
}
