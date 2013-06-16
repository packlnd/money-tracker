var min_pos = 559, max_pos = 816, MOUSE_DOWN, $slider;

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

$(".slider").mousedown(function(e) {
  MOUSE_DOWN = true;
  $slider = $(this);
});

function read_color(color) {
  return parseInt($(".slider#" + color).offset().left) - min_pos;
}

function hex_color() {
    var r = read_color("red"),
      g = read_color("green"),
      b = read_color("blue");
  return r.toString("16") + g.toString("16") + b.toString("16");
}

$(document).mousemove(function(e) {
  if (!MOUSE_DOWN || !$slider) {
    return;
  }
  var curr_pos = e.pageX;
  if (curr_pos > min_pos && curr_pos < max_pos) {
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
