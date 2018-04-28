function fillMap(selection, crimeData) {
	var slider_year = document.getElementById("year").value;
  // TODO: minor fix, sometimes d gets a -99, why?
  selection
    .crimeData(function filter_by_year(d){ if (d["YR"] <= slider_year) { return true; } });

}

function setPathTitle(selection, crimeData) {
		var slider_year = document.getElementById("year").value;
    selection
    .crimeData.filter(function filter_by_year(d){ if (d["YR"] <= slider_year) { return true; } });

}

function updateMap(crimeData) {

  // fill paths
  d3.selectAll("svg#map path").transition()
    .delay(100)
    .call(fillMap, crimeData);

  // update path titles
  d3.selectAll("svg#map path title")
    .call(setPathTitle, crimeData);
		
  // update headline
  d3.select("h2").text(headline + d3.select("#year").node().value);
}

