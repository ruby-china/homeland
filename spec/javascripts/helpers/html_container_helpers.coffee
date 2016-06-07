setupHtmlContainerHelper = (spec) ->

  beforeEach ->
    @htmlContainer = $("<div></div>").appendTo($("body"))

  afterEach ->
    @htmlContainer?.remove()
    @htmlContainer = null

setupHtmlContainerHelper(jasmine.Spec)
