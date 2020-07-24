$(document).ready(function () {
  $(document).on("click", "#initiative_no_signature", function() {
    if($(this).is(":checked")){
      $("#initiative_signature_end_date").val("");
      $(".signature-end-date").addClass("hide");
    } else {
      $(".signature-end-date").removeClass("hide");
    }
  });
});
