// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
  console.log("dentro de ready");

  $('#collapseOne').on('show.bs.collapse', function () {
    $("#glyp1").removeClass("glyphicon-eye-open").addClass("glyphicon-eye-close");
    $('#glyp1-font').html("Ocultar");
  });
 
  $('#collapseOne').on('hide.bs.collapse', function () {
    $("#glyp1").removeClass("glyphicon-eye-close").addClass("glyphicon-eye-open");
    $('#glyp1-font').html("Ver");
  });

  $('#collapseTwo').on('show.bs.collapse', function () {
    $("#glyp2").removeClass("glyphicon-eye-open").addClass("glyphicon-eye-close");
    $('#glyp2-font').html("Ocultar");
  });
 
  $('#collapseTwo').on('hide.bs.collapse', function () {
    $("#glyp2").removeClass("glyphicon-eye-close").addClass("glyphicon-eye-open");
    $('#glyp2-font').html("Ver");
  });
});
