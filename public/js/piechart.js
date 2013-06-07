function create_piechart(form, data_for_pie, pie_color) {
  (function basic_pie(container) {
    Flotr.draw(container, data_for_pie, {
      colors : pie_color,
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
