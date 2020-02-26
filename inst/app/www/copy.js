function copy(id) {
  var to_copy = document.getElementById(id);
  to_copy.select();
  document.execCommand("copy");
}