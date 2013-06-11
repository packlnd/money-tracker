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
      var json_categories = JSON.parse(xmlhttp.responseText);
      var pie_data = new Array();
      var colors = new Array();
      for (var name in json_categories) {
        var category = JSON.parse(json_categories[name]);
        if (category.sum == 0) {
          continue;
        }
        colors.push(category.color.toString());
        var sum = [[0, category.sum]];
        pie_data.push({ data : sum, label : name.toString() });
      }
      display_piechart(pie_data, colors);
      document.getElementById("pieheader").innerHTML = "<h4>Statistik per kategori från " + from + " till " + to + "</h4>";
      create_monthly_chart(from, to, categories);
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
      var json_categories = JSON.parse(xmlhttp.responseText);
      var chart_data = new Array();
      var colors = new Array();
      for (var name in json_categories) {
        category = JSON.parse(json_categories[name]);
        colors.push(category.color.toString());
        var m_data = new Array();
        var months = JSON.parse(category.months);
        for (var month in months) {
          if (months[month] == 0) {
            continue;
          }
          m_data.push([parseInt(month), parseInt(months[month])]);
        }
        chart_data.push({ data : m_data, label : name });
      }
      display_monthlychart(chart_data, colors);
      document.getElementById("monthlyheader").innerHTML = "<br/><h4>Statistik per månad och kategori för " + to.split('-')[0].toString();
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

function display_monthlychart(data, colors) {
  (function bars_stacked(container) {
    var d1 = [[0, 1], [1, 5]],
      d2 = [[0, 3], [1, 1]],
      d3 = [[0, 0], [1, 0]];
    Flotr.draw(container, data, {
      legend : { backgroundColor : '#FFF' },
      colors : colors,
      HtmlText : false,
      bars : {
        show : true,
        stacked : true,
        horizontal : false,
        barWidth : 0.5,
        lineWidth : 1,
        shadowSize : 0
      },
      grid : {
        verticalLines : false,
        horizontalLines : true
      }
    });
  })(document.getElementById("monthlychart"));
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
