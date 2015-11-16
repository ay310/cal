$(function() {
  var contents = $("#hover-click > div");
  $("#hover-click > a").click(function(){
    $(contents).toggle();
    return false;
  });
  $("#hover-click")
  .mouseover(function(){
    $(contents).show();
  })
  .mouseout(function(){
    $(contents).hide();
  });
});
