setupSinonSandbox = (spec, sinon) ->
  $.extend spec.prototype,
    fakeServer: ->
      @server ?= sinon.fakeServer.create()

    fakeXHR: ->
      return @xhr if @xhr
      fakeXHR = @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.requests = []
      @xhr.onCreate = (xhr) -> fakeXHR.requests.push xhr
      @xhr.responses = []
      @xhr

    respondXHRWith: (index, options = {}) ->
      @fakeXHR().responses[index] = responseFromOptions(options)

    respondWith: (urlOrRegExp, options = {}) ->
      type = options.type ? options.method
      response = responseFromOptions(options)
      if urlOrRegExp
        if type
          @fakeServer().respondWith(type, urlOrRegExp, response)
        else
          @fakeServer().respondWith(urlOrRegExp, response)
      else
        @fakeServer().respondWith(response)

    respondApiWith: (urlOrRegExp, options = {}) ->
      unless assert.isRegExp(urlOrRegExp)
        urlOrRegExp = [config.sync.ajax.urlRoot, config.sync.ajax.apiVersion].join('/') + urlOrRegExp
      @respondWith(urlOrRegExp, options)

    respond: ->
      @server?.respond()
      if @xhr
        for i in [0...@xhr.requests.length]
          if resp = @xhr.responses[i]
            @xhr.requests[i].respond resp...

    spy: (args...) ->
      @sinon.spy args...

    stub: (args...) ->
      @sinon.stub args...

  beforeEach ->
    @sinon = sinon.sandbox.create()

  afterEach ->
    @server?.restore()
    @xhr?.restore()
    @sinon.restore()

setupAjaxStub = (spec) ->
  # Use deferred object to trigger callback, so testing is synchronous. The
  # resolve or reject are invoked, all requests are executed and returned.
  #
  # It also can be applied to any other library based on $.Deferred
  jasmine.Spec::stubAjax = (object = $) ->
    @stub object, 'ajax', (options) ->
      # returns a new Deferred object so it supports all deferred methods,
      # also invokes the callbacks in options
      dfd = $.Deferred()
      dfd.done(options.done) if options.done
      dfd.done(options.success) if options.success
      dfd.fail(options.fail) if options.fail
      dfd.fail(options.error) if options.error
      dfd.always(options.always) if options.always
      dfd.always(options.complete) if options.complete

      dfd

setupDeferedPipe = (spec) ->
  beforeEach ->
    @pipePromise = $.Deferred().resolve().promise()

  spec::pipe = (success, error) ->
    # wrap callbacks with current context
    success = $.proxy(success, @)
    error = $.proxy(error, @)

    # setup args to ease test
    chained = @pipePromise = @pipePromise.pipe(success, error)
    chained.always (args...) -> chained.args = args

  spec::waitsForPromise = (promise, message = 'Waits for Promise', timeout = null) ->
    waitsFor ->
      promise.state() in ['resolved', 'rejected']
    , message, timeout

  spec::waitsForPipe = (message = 'Waits for Spec pipe', timeout = null) ->
    waitsFor ->
      @pipePromise.state() in ['resolved', 'rejected']
    , message, timeout

  spec::expectPipeResolved = ->
    runs ->
      expect(@pipePromise.state()).toEqual('resolved')

  spec::expectPipeResolvedWith = (args...) ->
    runs ->
      expect(@pipePromise.state()).toEqual('resolved')
      expect(@pipePromise.args).toEqual(args)

  spec::expectPipeRejected = ->
    runs ->
      expect(@pipePromise.state()).toEqual('rejected')

  spec::expectPipeRejectedWith = (args...) ->
    runs ->
      expect(@pipePromise.state()).toEqual('rejected')
      expect(@pipePromise.args).toEqual(args)

setupSinonSandbox(jasmine.Spec, sinon)
setupAjaxStub(jasmine.Spec)
setupDeferedPipe(jasmine.Spec)
