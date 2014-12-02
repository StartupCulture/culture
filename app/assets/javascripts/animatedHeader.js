// By: Henrique Breim
$(function(){
    $(window).scroll(function(){
        if ($(this).scrollTop() > 300){
            $('.navbar-home').addClass('navbar-shrink');
        }
        else{
            $('.navbar-home').removeClass('navbar-shrink');
        }
    });
});

