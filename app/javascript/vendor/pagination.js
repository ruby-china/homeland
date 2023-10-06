// Keyboard shortcuts for browsing pages of lists
(function($) {
    $(document).off("keydown.pagination");
    $(document).on("keydown.pagination", handleKey);
    function handleKey(e) {
        var left_arrow = 37;
        var right_arrow = 39;
        if (e.target.nodeName == 'BODY' || e.target.nodeName == 'HTML') {
                if (!e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey) {
                    var code = e.which;
                    if (code == left_arrow) {
                        prevPage();
                    }
                    else if (code == right_arrow) {
                        nextPage();
                    }
                }
            }
    }

    function prevPage() {
        var href = $('.pagination a[rel=prev]').attr('href');
        if (href && href != document.location && href != "#") {
            Turbolinks.visit(href);
        }
    }

    function nextPage() {
        var href = $('.pagination a[rel=next]').attr('href');
        if (href && href != document.location && href != "#") {
            Turbolinks.visit(href);
        }
    }
})(jQuery);
