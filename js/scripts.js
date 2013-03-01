$(document).ready(function() {

    $(".code-editor").click(function(){
        $(".intro").addClass('expanded').css({height:920});
    });

    $(".code-editor-browser ul li a").click(function(){
        $(this).next('ul').slideToggle(250);
    });

    $(".code-editor").hover(function(){
        if(!$('.intro').hasClass('expanded')) {
            $(".intro").css({height:402});
        }
    },function(){
        if(!$('.intro').hasClass('expanded')) {
            $(".intro").css({height:382});
        }
    });
});
