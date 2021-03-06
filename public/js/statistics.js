$(".charts").hide();
$(document).ready(create_statistics());

$("#from").datepicker({
  dateFormat: "yy-mm-dd",
  onClose: function(date){create_statistics()}
});

$("#to").datepicker({
  dateFormat: "yy-mm-dd",
  onClose: function(date){create_statistics()}
});

$("input.text_filter").keyup(function(){create_statistics();});
$("input.click_filter").click(function(){create_statistics();});

function create_statistics() {
  var from = $("#from").val(),
    to = $("#to").val(),
    categories = format_categories();

  create_pie_chart(from, to, categories);
}

function create_pie_chart(from, to, categories) {
  var url = "/statistics/get_pie_data/" + from + "/" + to + "/" + categories,
    func = function(response) {
      var json_categories = JSON.parse(response),
        pie_data = [],
        colors = [];
      for (var name in json_categories) {
        var category = JSON.parse(json_categories[name]);
        if (category.sum == 0) {
          continue;
        }
        colors.push(category.color.toString());
        var sum = [[0, category.sum]];
        pie_data.push({ data : sum, label : name.toString() });
      }
      display_piechart(pie_data, colors, "piechart");
      create_monthly_chart(to, categories);
    };
  handle_request(url, func);
}

function create_monthly_chart(to, categories) {
  var url = "/statistics/get_monthly_data/" + to + "/" + categories,
    func = function(response) {
      var json_categories = JSON.parse(response),
        chart_data = [],
        colors = [];
      for (var name in json_categories) {
        category = JSON.parse(json_categories[name]);
        colors.push(category.color.toString());
        var m_data = [],
          months = JSON.parse(category.months);
        for (var month in months) {
          if (months[month] == 0) {
            continue;
          }
          m_data.push([parseInt(month), parseInt(months[month])]);
        }
        chart_data.push({ data : m_data, label : name });
      }
      display_monthlychart(chart_data, colors, "monthlychart");
      create_result_chart(json_categories, date_to_year(to))
    };
  handle_request(url, func);
}

function date_to_year(date) {
  date.split('-')[0].toString();
}

function create_result_chart(json_categories, year) {
  var result_data = [],
    chart_data = [],
    pos_data = [],
    neg_data = [];
  for (var i = 0; i < 12; i++) {
    result_data.push([i,0]);
  }
  for (var name in json_categories) {
    category = JSON.parse(json_categories[name]);
    var months = JSON.parse(category.months);
    for (var month in months) {
      result_data[parseInt(month)][1] += parseInt(months[month]);
    }
  }
  for (var elem in result_data) {
    var sum = result_data[elem];
    if (sum[1] == 0) {
      continue;
    }
    sum[1] > 0 ? pos_data.push(sum) : neg_data.push(sum);
  }
  chart_data.push({data:pos_data, label:"POSITIVT"});
  chart_data.push({data:neg_data, label:"NEGATIVT"});
  display_monthlychart(chart_data, ['#468847', '#B84947'], "resultchart");
}

function display_monthlychart(data, colors, div) {
  $("#" + div).show();
  (function bars_stacked(container) {
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
      mouse : { track : true },
      grid : {
        verticalLines : false,
        horizontalLines : true
      }
    });
  })(document.getElementById(div));
}

function display_piechart(data, colors, div) {
  $("#" + div).show();
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
  })(document.getElementById(div));
}
