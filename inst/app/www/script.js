$(document).on('shiny:disconnected', function(event) {
  var dv = document.createElement("DIV"); 

  dv.innerHTML = "<h1>Whoops!</h1>" + 
    "<h3>You were disconnected</h3>" + 
    "<br/>" + 
    "<button class='btn btn-default' onclick='location.reload();'>Reload</button>"

  dv.className = "centered";

  document.body.appendChild(dv);
});