  var my_id;
  var folio_counter = 0;

// ############################### FUNCTIONS ######################################################                  
  function check_folio(){
    len = $('#folio_field').val().length;
    console.log(len);
    if(len==20){
     
      $("#img_fail_folio").hide();
      $("#img_ok_folio").show();
      return true;
    }
    else{
      $("#img_fail_folio").show();
      $("#img_ok_folio").hide();
      return false;
    }
   
  }
  
  function display_status(type,my_id){
    if(type=="ok"){
      $("#img_ok_"+my_id).css("display","inline-block");
      $("#img_load_"+my_id).css("display","none");
      $("#img_fail_"+my_id).css("display","none");

    }
    else if(type=="load"){
      //$(".reqdoc_button").prop("disabled","disabled");
      //$(".reqdoc_button_delete").prop("disabled","disabled");
      $("#img_ok_"+my_id).css("display","none");
      $("#img_load_"+my_id).css("display","inline-block");
      $("#img_fail_"+my_id).css("display","none");
      $("#img_load_"+my_id).css("display","inline-block");

    }
    else if(type=="fail"){
      $("#img_ok_"+my_id).css("display","none");
      $("#img_load_"+my_id).css("display","none");
      $("#img_fail_"+my_id).css("display","inline-block");
    }
  }
  
  function files_req_missing(){
    var files_req_missing  =  $(".img-ok:hidden")
    
    if(files_req_missing.length==0){
      $("#btn_ok").show();
    }else{
      $("#btn_ok").hide();
    }
  }
  
  function changeResourceImage(i_id,image_small,image_medium,image_status){
    
      if (image_status){
        
        $("#img_ok_11").css("display","inline-block");
        $("#img_fail_11").css("display","none");
      }else{
              
        $("#img_ok_11").css("display","none");
        $("#img_fail_11").css("display","inline-block");
      }
      
      files_req_missing()
  }

// ############################### NEW ######################################################                
$(document).ready(function() {
     
    $(".reqdoc_button_download").click(function(){
      my_id       = $(this).attr("my_id");
      var my_file_id  = $(this).attr("my_file_id");
      $("#files_iframe2").attr("src","/inscripcion/file/"+my_file_id);
    });

    $(".reqdoc_button_delete").click(function(){
      my_id       = $(this).attr("my_id");
      var my_file_id  = $(this).attr("my_file_id");
      display_status("load",my_id);
      
      $("#files_iframe2").attr("src","/inscripcion/destroy_file/"+my_file_id);
      files_req_missing()
    });


    $("#reqdoc_button_1").click(function(){
      my_id   = $(this).attr("my_id");
      var form_id = "#internship_file_file_"+my_id;
      var valor = $(form_id).val();

      p      = $(this).parent();
      f_type = p.find("#file_type").val();

      if(f_type==5)
      {
        var myRe = /\dfsdfsadsda$/i;
      }
      else
      {
        var myRe = /(\.pdf$)/i;
      }

      if(myRe.test(valor))
      {
        display_status("load",my_id);
        var form_id = "#reqdoc-form-"+my_id;
        $(form_id).submit();
      }else{
        if(f_type==5){
          var myRe = /\.pdf$/i;
          if(myRe.test(valor)){
            alert("Debe ser forzosamente imagen");
          }
          else
          {
            display_status("load",my_id);
            var form_id = "#reqdoc-form-"+my_id;
            $(form_id).submit();
          }
        }
        else
        {
          alert("Solo puedes subir archivos pdf");
        }
      }

      files_req_missing()
    });

    $("#files_iframe2").load(function(){
      var sts = $('#files_iframe2').contents().find("status").html();
      var ref = $('#files_iframe2').contents().find("reference").html();

      if(sts=="0")
      {
        errors  = $('#files_iframe2').contents().find("errors").html();
        alert(errors);

        if(ref=="upload"){
          display_status("fail",my_id);
        }
        else if(ref=='destroy')
        {
          display_status("ok",my_id);
        }
      }
      else if(sts=="1")
      {
        if(ref=="upload")
        {
          var new_id = $('#files_iframe2').contents().find("id").html();
          display_status("ok",my_id);
          
          $("#internship_file_file_"+my_id).hide()
          $("#internship_file_file_label_"+my_id).hide();

          $("#reqdoc_button_"+my_id).hide();
          $("#reqdoc_button_download_"+my_id).show();
          $("#reqdoc_button_delete_"+my_id).show();
         
          $("#reqdoc_button_"+my_id).attr("my_file_id",new_id);
          $("#reqdoc_button_download_"+my_id).attr("my_file_id",new_id);
          $("#reqdoc_button_delete_"+my_id).attr("my_file_id",new_id);
         
          text = "El archivo se ha subido correctamente al servidor!!";
          $("#file_message").html(text)
          text = $('#files_iframe2').contents().find("name").html();
          $("#file_description").html('['+text+']')
        }
        else if(ref=="destroy")
        {
          display_status("fail",my_id);
          $("#internship_file_file_"+my_id).val("");
          $("#internship_file_file_"+my_id).css("display","inline-block");
          
          $("#internship_file_file_label_"+my_id).html("Seleccionar archivo");
          $("#internship_file_file_label_"+my_id).css("display","inline-block");

          $("#reqdoc_button_"+my_id).css("display","inline-block");
          $("#reqdoc_button_download_"+my_id).css("display","none");
          $("#reqdoc_button_delete_"+my_id).css("display","none");
         
          text = "No se ha subido el archivo";
          $("#file_message").html(text)
          $("#file_description").html("")
         
        }


        $(".reqdoc_button").removeAttr("disabled");
        $(".reqdoc_button_delete").removeAttr("disabled");

        files_req_missing();

      }
    });

      $('.inputfile').change(function(){
        var filename = $(this).val().split('\\').pop();
        var idname   = $(this).attr('id');                 
        var myid     = idname.split('_').pop();
                
        $('#reqdoc_button_'+myid).removeClass("disabled");
        $('#reqdoc_button_'+myid).removeAttr("disabled");
        
        $('#tooltip_'+idname.split('_').pop()).html(filename);
        $('#'+idname).next().html(filename.slice(0,17));
      });
      
      $('.inputfile+label').mouseover(function(){
        var idname   = $(this).attr('id');
        var tooltip = '#tooltip_'+idname.split('_').pop()
        console.log('|'+tooltip+'|');
        $(tooltip).css("visibility","visible");
      });
      
      $('.inputfile+label').mouseout(function(){
        var idname   = $(this).attr('id');
        var tooltip = '#tooltip_'+idname.split('_').pop()
        console.log(tooltip);
        $(tooltip).css("visibility","hidden");
      });
        
    $('#folio_field').keyup(function(){
       check_folio();
       files_req_missing();
     });
     
     $('#folio_field').focusout(function(){
       check_folio();
       files_req_missing();
     });                  
                  
  // ############################### OLD ######################################################                
                  
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
