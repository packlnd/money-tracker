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
