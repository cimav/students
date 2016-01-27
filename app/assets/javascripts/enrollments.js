$(document).ready(function() {
  $("#btn_ok").click(function (){ 
    $("#ajax_load").show();
    var folio  = $("#folio_field").val();
    folio = folio.replace(/ /g,'')
    if(!folio)
    {   
      alert("Debe capturar un folio");
      $("#ajax_load").hide();
      return false;
    }   
    var my_id  = $("#hidden_id").val(); 
    var s_id   = $("#s_id").val();
    var url    = "/inscripcion/folio/"+folio;
    $.ajax({
      type: 'GET',
      url: url,
      success: function(data){
         if(data.errors.length<=0){
           /*$('#btn_ok').prop("disabled",true); 
             $("#folio_field").prop("disabled",true); */

           $d     = $("#new-enrollment-dialog");
           $("#nedCloseButton").click(function(){$d.dialog("close")});
           loadCourses(my_id,$d);
           $d.dialog("open");
           $(".ui-widget-overlay").css("position","absolute");
           $(".ui-widget-overlay").css("top","0");
         }
         else
         {
           alert("Avisos: "+data.errors)
         }
      },
      error: function(xhr, textStatus, error){
         alert("Error al buscar folio, intentar de nuevo, si el error persiste comunicarse a posgrado");
      },
      complete: function(){
         $("#ajax_load").hide();
      }
    }); 
  });

  $("#help_ico").click(function(){
    d      = $("#help-dialog");
    d.dialog("open");
  });


  $("#new-enrollment-dialog").dialog({ 
    autoOpen: false, 
    width: 640, 
    height: 450, 
    modal:true, 
    dialogClass: "no-close",
  });

  $("#help-dialog").dialog({
    autoOpen: false,
    width: 800,
    height: 600,
  });

  $('#assign-courses-form')
    .live("ajax:beforeSend",function(evt,xht,settings){
      checks      = $("input[name='tcourses[]']:checked").length
      none        = $("#chk_none").prop("checked")
      //$("#hfolio").val($("#folio_field").val());
      
      if(none==true){
        return true
      }
      else{
        if(checks>0){
          return true;
        }
        else{
          alert("Tiene que elegir materias");
          return false;
        }
      }
    })
    .live("ajax:error", function(data, status) {
      console.log(data);
      console.log(status);
    }) 
    .live('ajax:success', function(evt, data, status, xhr) {
      var res  = $.parseJSON(xhr.responseText);
      var errs = res['errors']
      if(errs.length==0){
        // TODO OK :3
        $("#new-enrollment-dialog").dialog("close");
        $("#folio_field").prop("disabled",true); 
        $("#clock-div").show(); 
        $("#refused-div").hide(); 
        $(".materias").hide(); 
        $('#btn_ok').hide(); 
        /*$('#img_fail_'+res['s_id']).css("display","none");
        $('#img_ok_'+res['s_id']).css("display","block");
        $('#text_'+res['s_id']).html("[Materias Elegidas]");
        $('#'+res['s_id']).attr('status',0);*/
        
      }else{
        alert("Se presentaron los siguientes errores: "+res['message']+"("+errs+")")
      }

      /*var errs = $.map(res['errors'],function(value,index){
        return [value];
      });*/
    });

  function loadCourses(my_id,$d)
  {
    $.ajax({ 
      url: "/alumnos/inscripcion/materias/"+my_id,
      type: "POST",
      data: "folio_field="+$("#folio_field").val(),
    })
      .done(function( html ) {
        $("#courses").html(html);
      })
      .fail(function() {
        $("#courses").html("Error al traer los cursos");
      })
     .always(function() {
       hstatus = $('#hstatus').val()
       if (hstatus == 1) {
         $('#nedSendButton')
           .removeAttr("disabled")
           .click(function () {  $("#assign-courses-form").submit();  });
       }
     });
  }
});
