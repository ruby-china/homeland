window.EmojiModalView = Backbone.View.extend
  className: 'emoji-modal modal'

  panels: {}

  events:
    "click .tab-pane a.emoji": "insertCode"
    "mouseover .tab-pane a.emoji": "preview"
    "click .nav-tabs li a": "changePanel"

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
    for group in EMOJI_GROUPS
      @addGroup(group)

    @activeFirstPanel()

  activeFirstPanel: ->
    @.$el.find('.nav-tabs li').first().addClass('active')
    firstGroupName = @.$el.find('.nav-tabs li a').first().data("group")
    tabPane = @.$el.find("#emoji-group-#{firstGroupName}")
    tabPane.html(@panels[firstGroupName])
    tabPane.addClass("active")

  findEmojiUrlByName: (name) ->
    emoji = _.find EMOJI_LIST, (emoji) ->
      return emoji.code == ":#{name}:"
    if !emoji
      return ""
    return "#{App.twemoji_url}/svg/#{emoji.url}.svg"

  addGroup: (group) ->
    @renderGroupHTML(group)
    if group.name == 'favorites'
      return false if group.icons.length == 0
    navTab = """
      <li><a href="#emoji-group-#{group.name}"
             data-group="#{group.name}" role="tab"
             data-toggle="tab">
          <img src="#{@findEmojiUrlByName(group.tabicon)}" class="twemoji" /></a>
      </li>
    """
    navPanel = """
    <div id="emoji-group-#{group.name}" class="tab-pane">
    </div>
    """

    @.$el.find('.nav-tabs').append(navTab)
    @.$el.find('.tab-content').append(navPanel)

  renderGroupHTML: (group) ->
    emojis = []
    if group.name == 'favorites'
      group.icons = _.pluck(@favoriteEmojis(), 'code')
    for emojiName in group.icons
      url = @findEmojiUrlByName(emojiName)
      if !url
        continue
      emojis.push "<a href='#' title='#{emojiName}' data-code='#{emojiName}' class='emoji'><img src='#{url}' class='twemoji' /></a>"
    @panels[group.name] = emojis.join('')

  changePanel: (e) ->
    groupName = $(e.currentTarget).data('group')
    $("#emoji-group-#{groupName}").html(@panels[groupName])

  insertCode: (e) ->
    target = $(e.currentTarget)
    code = target.data('code')
    @saveFavoritEmoji(code)
    window._editor.insertString(":#{code}: ")
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

  saveFavoritEmoji: (code) ->
    emojis = @favoriteEmojis()
    emoji = _.find emojis, (item) ->
      return item.code == code
    if !emoji
      emoji = { code: code, hits: 0 }
      emojis.push(emoji)
    emoji.hits += 1
    emojis = _.sortBy emojis, (item) ->
      return 0 - item.hits
    emojis = _.first(emojis, 100)
    localStorage.setItem('favorite-emojis', JSON.stringify(emojis))
    @renderGroupHTML(EMOJI_GROUPS[0])

  favoriteEmojis: ->
    return [] if !window.localStorage
    try
      JSON.parse(localStorage.getItem('favorite-emojis') || '[]')
    catch
      []
