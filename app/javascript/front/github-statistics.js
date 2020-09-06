window.GitHubStatisticsView = Backbone.View.extend({
  el: "body",
  events: {
    "click button#display-all": "toggleDisplayAll"
  },
  initialize: function(opts) {
    this.parentView = opts.parentView;
    return $('tr.not_testehome_user').attr('style', 'display: none');
  },
  toggleDisplayAll: function(e) {
    var btn, infoTable;
    btn = $(e.currentTarget);
    infoTable = btn.data('target');
    if (btn.hasClass("active")) {
      return $('table.' + infoTable + ' tr.not_testehome_user').attr('style', 'display: none');
    } else {
      btn.removeClass("focus");
      return $('table.' + infoTable + ' tr.not_testehome_user').removeAttr('style', '');
    }
  }
});
