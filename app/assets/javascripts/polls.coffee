window.Poll =
  el: "#poll-view"
  form: "#poll-form-modal"

  optionColorize: ->
    $("table .progress-bar", @el).each ->
      percent = $(this).data("percent")
      h = 100 - parseInt(percent, 10)
      $(this).css("backgroundColor", "hsl(#{h},80%,60%)")

  _votingState: false
  toggleVoting: (t) ->
    if t is "hide"
      $("input[name=vote-choice]", @el).addClass("hide")
      $("input[name=vote-choices]", @el).addClass("hide")
      $("button[name=btn_vote_submit]", @el).addClass("hide")
      @_votingState = false
    else
      $("input[name=vote-choice]", @el).removeClass("hide")
      $("input[name=vote-choices]", @el).removeClass("hide")
      $("button[name=btn_vote_submit]", @el).removeClass("hide")
      @_votingState = true

  _multipleMode: ->
    opts = $("table.poll-table", @el).find(".checkbox")
    if opts.length > 0
      return true
    opt = $("table.poll-table", @el).find(".radio")
    if opt.length > 0
      return false
    return null

  _getOption: ->
    opt = ""
    opt_sel = "input[name=vote-choice]"
    if $(opt_sel, @el).length > 0
      opt = $(opt_sel + ":checked", @el).val()
    return opt

  _getOptions: ->
    opts = []
    opt_sel = "input[name=vote-choices]"
    if $(opt_sel, @el).length > 0
      $(opt_sel + ":checked", @el).each ->
        opts.push $(this).val()
    return opts

  voting: ->
    _self = @
    $(@el).on 'click', "button[name=btn_voting]", (e) ->
      if _self._votingState
        _self.toggleVoting("hide")
        $(this).text("投票")
        $("input[name=vote-choice]:checked", @el).each ->
          $(this).prop("checked", false)
        $("input[name=vote-choices]:checked", @el).each ->
          $(this).prop("checked", false)
      else
        _self.toggleVoting()
        $(this).text("取消")

  voteSubmit: ->
    _self = @
    $(@el).on 'click', "button[name=btn_vote_submit]", (e) ->
      poll_id = $(this).data("poll-id")
      multi = _self._multipleMode()
      if (multi is null) or (not /^\d+$/.test(poll_id))
        return false
      opts = []
      if multi is true
        opts = _self._getOptions()
      else
        opt = _self._getOption()
        opts = [opt] if opt
      if opts.length < 1
        alert "Please choose."
        return false
      console.log poll_id
      $.ajax
        url: "/polls/#{poll_id}"
        type: "PUT"
        data: {oids: opts}
        success: (status) ->
          console.log status.msg if not status.voted
          # Turbolinks.visit location.href # not work properly
          window.location.reload(true)
          return
        error: (resp) ->
          alert "出错, 请稍后重试? #{resp.status} #{resp.statusText}"
          return
      return false

  showVoters: ->
    _self = @
    # setup popover
    $("a.voters-popover", @el).each ->
      $el = $(this)
      $el.popover
        html: true
        content:'<center><i class="fa fa-spin fa-spinner"></i></center>'
      $el.on 'shown.bs.popover', ->
        $popover = $el.next()
        $popover.find("div.arrow").remove()
        oid = $el.data('oid')
        pid = $el.data("poll-id")
        url = "/polls/#{pid}/voters?oid=#{oid}"
        resp = $.get url
        resp.done (html) ->
          $popover.find('div.popover-content').html(html)
        resp.fail ->
          $popover.find('div.popover-content').empty()
    # alternative next page
    $(_self.el).on 'click', "a.voters-next-page", (e) ->
      $voters_list = $(e.target).parent()
      next_url = $voters_list.find(".pagination a[rel=next]").attr("href")
      if /\/polls\//.test(next_url)
        console.log next_url
        resp = $.get next_url
        resp.done (html) ->
          $voters_list.replaceWith(html)
        resp.fail ->
          $voters_list.empty()
      else
        $voters_list.empty()

  formRemoveOption: ->
    $(@form).on 'click', ".poll-options button[name=remove-option]", (e) ->
      $(this).parent().parent().remove()

  formOptionsCount: ->
    $(@form).find(".poll-options .input-group").length

  maxOptionsCount: ->
    return parseInt($(@form).find(".poll-options").data("max-options"), 10)

  _optTmpl: '''
<div class="input-group">
  <input type="text" name="poll[options][]" placeholder="选项描述" maxlength="140" class="form-control input-sm"/>
  <span class="input-group-btn">
    <button class="btn btn-default btn-sm" name="remove-option" tabindex="-1" type="button"><i class="fa fa-times"></i></button>
  </span>
</div>
'''

  formAddOption: ->
    $(@form).on 'click', "button[name=add-option]", (e) =>
      if @formOptionsCount() >= @maxOptionsCount()
        alert("超出选项限制数: " + @maxOptionsCount())
      else
        $(@_optTmpl).appendTo $(".poll-options", @form)

  formSave: ->
    $(@form).on 'click', "button[name=btn-poll-complete]", (e) =>
      if @formOptionsCount() < 2
        alert "至少两个不同选项."
        return false
      opts = []
      dups = ""
      $(".poll-options input[name='poll[options][]']", @form).each ->
        desc = $(this).val().trim().replace(/\s+/, ' ')
        if desc is "" or _.indexOf(opts, desc) isnt -1
          dups = "选项不能重复."
        else
          opts.push desc
      if _.uniq(opts).length < 2 or dups isnt ""
        alert "至少两个不同选项. #{dups}"
        return false
      $("input[name='poll[save]']", @form).val("true")
      $(@form).modal('hide')

  formCancel: ->
    $(@form).on 'click', "button[name=btn-poll-cancel]", (e) =>
      $("input[name='poll[save]']", @form).val("false")
      $(@form).modal('hide')

  setupForm: ->
    @formRemoveOption()
    @formAddOption()
    @formSave()
    @formCancel()

  setup: ->
    @optionColorize()
    @voting()
    @voteSubmit()
    @showVoters()
    @setupForm()
