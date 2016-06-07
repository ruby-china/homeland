App.lastGotoUrl = null
App.gotoUrl = (url) ->
  App.lastGotoUrl = url

App.lastOpenUrl = null
App.openUrl = (url) ->
  App.lastOpenUrl = url

beforeEach ->
  App.lastGotoUrl = null
  App.lastOpenUrl = null

