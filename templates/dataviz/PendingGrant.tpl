{crmTitle string="<span class='total'></span> pending grants"}
<style>
{literal}
.page-civicrm-dataviz #crm-container div.graph.dc-chart {float:none;}
.page-civicrm-dataviz #crm-container div.dc-chart {margin:0;}
.page-civicrm-dataviz #crm-container [class^="col-md-"] {margin:0;}
{/literal}
</style>
<div class="row">
<div id="type" class="col-md-3"><h3>Type</h3><div class="graph col-md-"></div></div>
<div id="region" class="col-md-3"><h3>Regions</h3><div class="graph col-md-"></div></div>
<div id="date" class="col-md-6"><h3>Date</h3><div class="graph"></div></div>
</div>

<div class="row"><div class="col-md-12">
<h3>Latest 1000 grants</h3>
<table class="table table-striped" id="table">

<thead><tr>
<th>Received</th>
<th>Name</th>
<th>Country</th>
<th>Subtype</th>
<th>Amount</th>
</tr></thead>
</table>
</div>
</div>

<script>
{literal}
var countries={};
{/literal}
var data={crmSQL file="pendinggrant"};
var regions={crmAPI entity='Country' action='getoptions' sequential=0 field="region_id"}.values;
{php}
  $this->assign("param_options", ['limit' => 10000]);
{/php}
var t={crmAPI entity='Country' action='get' return="iso_code,name" options=$param_options}.values;


var statuses={crmAPI entity='Grant' action='getoptions' sequential=0 field="grant_status_id"}.values;
var types={crmAPI entity='Grant' action='getoptions' sequential=0 field="grant_type_id"}.values;
{literal}
//"keys":["id","contact_id","application_received_date","decision_date","money_transfer_date","grant_due_date","grant_report_received","grant_type_id","amount_total","amount_requested","amount_granted","rationale","status_id","currency","financial_type_id"]
var dateFormat = d3.time.format("%Y-%m-%d");
var graphs ={};
preProcess();
var ndx  = crossfilter(data.values);
draw();

function preProcess(){
  t.forEach(function(d){
    countries[d.iso_code]=d.name;
  });

  data.values.forEach(function(d){
    d.region=parseInt(d.region.split('\u0001')[1]);
    d.country=d.country.split('\u0001')[1];
    d.date = dateFormat.parse(d.application_received_date || d.money_transfer_date || "2020-01-01");
  });

}

function drawNumber() {
  var group=ndx.groupAll();
  return dc.numberDisplay(".total")
   .group(group)
   .valueAccessor(function(d) {return d})
}

function draw(){
  graphs.total=drawNumber();
  graphs.table=drawTable("#table");
  graphs.type=drawType("#type .graph");
  graphs.date=drawDate("#date .graph");
  graphs.region=drawRegion("#region .graph");
  graphs.type.on("pretransition",function(){
//    d3.selectAll(".dc-chart").classed("dc-chart",false).style("float","none")
  });

  dc.renderAll();

}

function drawRegion (dom) {

  var dim = ndx.dimension(function(d){return regions[d.region]});
  var group = dim.group().reduceSum(function(d){return 1;});
  var graph  = dc.pieChart(dom)
    .innerRadius(10).radius(60)
    .width(120)
    .height(120)
    .dimension(dim)
//    .colors(d3.scale.category20b())
    .group(group);

  return graph;
}
function drawType (dom) {
  var dim = ndx.dimension(function(d){return types[d.grant_type_id]});
  var group = dim.group().reduceSum(function(d){return 1;});
  var graph  = dc.pieChart(dom)
    .innerRadius(10).radius(60)
    .width(120)
    .height(120)
    .dimension(dim)
//    .colors(d3.scale.category20b())
    .group(group);

  return graph;
}

function drawDate (dom) {
  var dim = ndx.dimension(function(d){return d3.time.month(d.date || new Date())});
  var group = dim.group().reduceSum(function(d){return 1;});
  var minDate = dim.bottom(1)[0]["date"];
  var maxDate = dim.top(1)[0]["date"];
  var graph=dc.barChart(dom)
   .margins({top: 10, right: 10, bottom: 20, left:50})
    .height(120)
    .width(350)
    .dimension(dim)
    .group(group)
    .brushOn(true)
    .x(d3.time.scale().domain([minDate, maxDate]).nice(d3.time.month))
    .round(d3.time.day.round)
    .elasticY(true)
    .xUnits(d3.time.months);

   graph.yAxis().ticks(3);
   graph.xAxis().ticks(5);
  return graph;
}

function drawTable(dom) {
  var dim = ndx.dimension (function(d) {return d.id});
  var graph = dc.dataTable(dom)
    .dimension(dim)
    .size(1000)
    .group(function(d){ return ""; })
    .sortBy(function(d){ return d.date; })
    .order(d3.descending)
//"keys":["id","contact_id","application_received_date","decision_date","money_transfer_date","grant_due_date","grant_report_received","grant_type_id","amount_total","amount_requested","amount_granted","rationale","status_id","currency","financial_type_id"]
    .columns(
	[
	    function (d) {return "<a href='"+CRM.url('civicrm/contact/view/grant',{'action':'view','reset':1,'cid':d.contact_id,'id':d.id})+"'>"+d.application_received_date+"</a>";}, 
	    function (d) {return "<a href='"+CRM.url('civicrm/contact/view', {"reset": 1, "cid": d.contact_id})+"'>"+ ((d.display_name) || "?") + "</a>";}, 
	    function (d) {return countries[d.country] || "?"}, 
	    function (d) {return d.sub_type}, 
	    function (d) {return CRM.formatMoney(d.amount_total) }, 
	]
    );

  return graph;
}

 

{/literal}
</script>
