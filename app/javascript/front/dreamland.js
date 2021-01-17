$(function() {
    $(".check-in").on("click", function (e){
        $.post(`/check_in`);
        $(".check-in").hide();
        const html = `<div class='alert alert-success'><button class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span></button>签到成功，积分+2</div>`;
        $("#main").prepend(html);
    })
})