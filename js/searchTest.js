"use strict";

//Create an instance of the search object.
var Sch;

var searchQueryTests = [
  'appearance',
  '+yellow  -red "two colours"  green'
];

function setupTests(){
  Sch = new StaticSearch();
  //document.getElementById('doSearch').addEventListener('click', function(){Sch.parseSearchQuery(); Sch.writeSearchReport(); return false;});
  document.getElementById('searchQuery').value = searchQueryTests[1];
}

window.addEventListener('load', setupTests);
