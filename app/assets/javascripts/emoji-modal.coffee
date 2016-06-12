window.EmojiModalView = Backbone.View.extend
  className: 'emoji-modal modal'

  events:
    "click .tab-pane a.emoji": "insertCode"
    "mouseover .tab-pane a.emoji": "preview"

  initialize: ->
    @.$el.html("""
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <ul class="nav nav-tabs">
          </ul>
        </div>
        <div class="modal-body">
          <div class="tab-content">
          </div>
        </div>
        <div class="modal-footer">
        </div>
      </div>
    </div>
    """)
    t1 = new Date()
    for group in EMOJI_GROUPS
      @addGroup(group)
    t2 = new Date()
    console.log(t2 - t1)
    @.$el.find('.nav-tabs li').first().addClass('active')
    @.$el.find('.tab-pane').first().addClass('active')

  findEmojiUrlByName: (name) ->
    emoji = _.find EMOJI_LIST, (emoji) ->
      return emoji.code == ":#{name}:"
    if !emoji
      return ""
    return "#{App.twemoji_url}/svg/#{emoji.url}.svg"

  addGroup: (group) ->
    navTab = "<li><a href='#emoji-group-#{group.name}' role='tab' data-toggle='tab'><img src='#{@findEmojiUrlByName(group.tabicon)}' class='twemoji' /></a></li>"
    emojis = []
    for emojiName in group.icons
      url = @findEmojiUrlByName(emojiName)
      continue if !url
      emojis.push "<a href='#' title='#{emojiName}' data-code='#{emojiName}' class='emoji'><img src='#{url}' class='twemoji' /></a>"
    navPanel = """
    <div id="emoji-group-#{group.name}" class="tab-pane">
      #{emojis.join('')}
    </div>
    """
    @.$el.find('.nav-tabs').append(navTab)
    @.$el.find('.tab-content').append(navPanel)

  insertCode: (e) ->
    target = $(e.currentTarget)
    code = ":#{target.data('code')}: "
    window._topicView.insertString(code)
    return false

  preview: (e) ->
    target = $(e.currentTarget)
    emojiName = target.data('code')
    code = ":#{target.data('code')}: "
    html = "<img class='emoji' src='#{@findEmojiUrlByName(emojiName)}' /> #{code}"
    @.$el.find('.modal-footer').html(html)

  show: ->
    if $('.emoji-modal').size() == 0
      $('body').append(@.$el)
    @.$el.modal('show')

  hide: ->
    @.$el.modal('hide')
