function create_statistics(form, number_of_categories) {
  var from = form.elements["date_from"].value;
  var to = form.elements["date_to"].value;
  var categories = format_categories(form, number_of_categories)

  create_pie_chart(from, to, categories);
}

function create_pie_chart(from, to, categories) {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      var categories = JSON.parse(xmlhttp.responseText);
      var pie_data = new Array();
      var colors = new Array();
      for (var name in categories) {
        var category = JSON.parse(categories[name]);
        if (category.sum == 0) {
          continue;
        }
        colors.push(category.color.toString());
        var sum = [[0, category.sum]];
        pie_data.push({ data : sum, label : name.toString() });
      }
      display_piechart(pie_data, colors);
    }
  }
  var url = "/statistics/get_pie_data/" + from + "/" + to + "/" + categories;
  xmlhttp.open("GET", url, true);
  xmlhttp.send();
}

function create_monthly_chart(from, to, categories) {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
    }
  }
  var url = "/statistics/get_monthly_data/" + from + "/" + to + "/" + categories;
  xmlhttp.open("GET", url, true);
  xmlhttp.send();
}

function format_categories(form, number_of_categories) {
  var s = "";
  for (var i = 1; i < number_of_categories+1; i++) {
    if (form.elements["category[" + i + "]"].checked) {
      s += "." + i;
    }
  }
  return s.substring(1);
}

function display_piechart(data, colors) {
  (function basic_pie(container) {
    Flotr.draw(container, data, {
      colors : colors,
      HtmlText : false,
      grid : {
        verticalLines : false,
        horizontalLines : false,
        outlineWidth:0
      },
      xaxis : { showLabels : false },
      yaxis : { showLabels : false },
      pie : { show : true },
      mouse : { track : true },
      legend : {
        position : 'se',
        backgroundColor : '#FFF'
      }
    });
  })(document.getElementById("piechart"));
}
