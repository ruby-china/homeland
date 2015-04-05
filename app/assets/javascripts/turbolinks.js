var CSRFToken, Click, ComponentUrl, EVENTS, Link, ProgressBar, ProgressBarAPI, browserIsntBuggy, browserSupportsCustomEvents, browserSupportsPushState, browserSupportsTurbolinks, bypassOnLoadPopstate, cacheCurrentPage, cacheSize, changePage, clone, constrainPageCacheTo, createDocument, crossOriginRedirect, currentState, disableRequestCaching, enableTransitionCache, executeScriptTags, extractTitleAndBody, fetch, fetchHistory, fetchReplacement, findNodes, findNodesMatchingKeys, historyStateIsDefined, initializeTurbolinks, installDocumentReadyPageEventTriggers, installHistoryChangeHandler, installJqueryAjaxSuccessPageUpdateTrigger, loadedAssets, manuallyTriggerHashChangeForFirefox, pageCache, pageChangePrevented, pagesCached, popCookie, processResponse, progressBar, recallScrollPosition, referer, reflectNewUrl, reflectRedirectedUrl, rememberCurrentState, rememberCurrentUrl, rememberReferer, removeNoscriptTags, replace, requestCachingEnabled, requestMethodIsSafe, resetScrollPosition, setAutofocusElement, swapNodes, transitionCacheEnabled, transitionCacheFor, triggerEvent, uniqueId, visit, xhr, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

pageCache = {};

cacheSize = 10;

transitionCacheEnabled = false;

requestCachingEnabled = true;

progressBar = null;

currentState = null;

loadedAssets = null;

referer = null;

xhr = null;

EVENTS = {
  BEFORE_CHANGE: 'page:before-change',
  FETCH: 'page:fetch',
  RECEIVE: 'page:receive',
  CHANGE: 'page:change',
  UPDATE: 'page:update',
  LOAD: 'page:load',
  RESTORE: 'page:restore',
  BEFORE_UNLOAD: 'page:before-unload',
  EXPIRE: 'page:expire'
};

fetch = function(url, options) {
  var cachedPage;

  if (options == null) {
    options = {};
  }
  url = new ComponentUrl(url);
  rememberReferer();
  cacheCurrentPage();
  if (progressBar != null) {
    progressBar.start();
  }
  if (transitionCacheEnabled && (cachedPage = transitionCacheFor(url.absolute))) {
    fetchHistory(cachedPage);
    options.showProgressBar = false;
    return fetchReplacement(url, options);
  } else {
    options.onLoadFunction = resetScrollPosition;
    return fetchReplacement(url, options);
  }
};

transitionCacheFor = function(url) {
  var cachedPage;

  cachedPage = pageCache[url];
  if (cachedPage && !cachedPage.transitionCacheDisabled) {
    return cachedPage;
  }
};

enableTransitionCache = function(enable) {
  if (enable == null) {
    enable = true;
  }
  return transitionCacheEnabled = enable;
};

disableRequestCaching = function(disable) {
  if (disable == null) {
    disable = true;
  }
  requestCachingEnabled = !disable;
  return disable;
};

fetchReplacement = function(url, options) {
  var _ref, _ref1,
    _this = this;

  if ((_ref = options.cacheRequest) == null) {
    options.cacheRequest = requestCachingEnabled;
  }
  if ((_ref1 = options.showProgressBar) == null) {
    options.showProgressBar = true;
  }
  triggerEvent(EVENTS.FETCH, {
    url: url.absolute
  });
  if (xhr != null) {
    xhr.abort();
  }
  xhr = new XMLHttpRequest;
  xhr.open('GET', url.formatForXHR({
    cache: options.cacheRequest
  }), true);
  xhr.setRequestHeader('Accept', 'text/html, application/xhtml+xml, application/xml');
  xhr.setRequestHeader('X-XHR-Referer', referer);
  xhr.onload = function() {
    var doc;

    triggerEvent(EVENTS.RECEIVE, {
      url: url.absolute
    });
    if (doc = processResponse()) {
      reflectNewUrl(url);
      reflectRedirectedUrl();
      changePage(doc, options);
      if (options.showProgressBar) {
        if (progressBar != null) {
          progressBar.done();
        }
      }
      manuallyTriggerHashChangeForFirefox();
      if (typeof options.onLoadFunction === "function") {
        options.onLoadFunction();
      }
      return triggerEvent(EVENTS.LOAD);
    } else {
      if (progressBar != null) {
        progressBar.done();
      }
      return document.location.href = crossOriginRedirect() || url.absolute;
    }
  };
  if (progressBar && options.showProgressBar) {
    xhr.onprogress = function(event) {
      var percent;

      percent = event.lengthComputable ? event.loaded / event.total * 100 : progressBar.value + (100 - progressBar.value) / 10;
      return progressBar.advanceTo(percent);
    };
  }
  xhr.onloadend = function() {
    return xhr = null;
  };
  xhr.onerror = function() {
    return document.location.href = url.absolute;
  };
  return xhr.send();
};

fetchHistory = function(cachedPage) {
  if (xhr != null) {
    xhr.abort();
  }
  changePage(createDocument(cachedPage.body.outerHTML), {
    title: cachedPage.title,
    runScripts: false
  });
  if (progressBar != null) {
    progressBar.done();
  }
  recallScrollPosition(cachedPage);
  return triggerEvent(EVENTS.RESTORE);
};

cacheCurrentPage = function() {
  var currentStateUrl;

  currentStateUrl = new ComponentUrl(currentState.url);
  pageCache[currentStateUrl.absolute] = {
    url: currentStateUrl.relative,
    body: document.body,
    title: document.title,
    positionY: window.pageYOffset,
    positionX: window.pageXOffset,
    cachedAt: new Date().getTime(),
    transitionCacheDisabled: document.querySelector('[data-no-transition-cache]') != null
  };
  return constrainPageCacheTo(cacheSize);
};

pagesCached = function(size) {
  if (size == null) {
    size = cacheSize;
  }
  if (/^[\d]+$/.test(size)) {
    return cacheSize = parseInt(size);
  }
};

constrainPageCacheTo = function(limit) {
  var cacheTimesRecentFirst, key, pageCacheKeys, _i, _len, _results;

  pageCacheKeys = Object.keys(pageCache);
  cacheTimesRecentFirst = pageCacheKeys.map(function(url) {
    return pageCache[url].cachedAt;
  }).sort(function(a, b) {
    return b - a;
  });
  _results = [];
  for (_i = 0, _len = pageCacheKeys.length; _i < _len; _i++) {
    key = pageCacheKeys[_i];
    if (!(pageCache[key].cachedAt <= cacheTimesRecentFirst[limit])) {
      continue;
    }
    triggerEvent(EVENTS.EXPIRE, pageCache[key]);
    _results.push(delete pageCache[key]);
  }
  return _results;
};

replace = function(html, options) {
  if (options == null) {
    options = {};
  }
  return changePage(createDocument(html), options);
};

changePage = function(doc, options) {
  var csrfToken, nodesToBeKept, targetBody, title, _ref;

  _ref = extractTitleAndBody(doc), title = _ref[0], targetBody = _ref[1], csrfToken = _ref[2];
  if (title == null) {
    title = options.title;
  }
  triggerEvent(EVENTS.BEFORE_UNLOAD);
  document.title = title;
  swapNodes(targetBody, findNodes(document.body, '[data-turbolinks-temporary]'), {
    keep: false
  });
  if (options.change) {
    swapNodes(targetBody, findNodesMatchingKeys(document.body, options.change), {
      keep: false
    });
  } else {
    if (!options.flush) {
      nodesToBeKept = findNodes(document.body, '[data-turbolinks-permanent]');
      if (options.keep) {
        nodesToBeKept.push.apply(nodesToBeKept, findNodesMatchingKeys(document.body, options.keep));
      }
      swapNodes(targetBody, nodesToBeKept, {
        keep: true
      });
    }
    document.documentElement.replaceChild(targetBody, document.body);
    if (csrfToken != null) {
      CSRFToken.update(csrfToken);
    }
    setAutofocusElement();
  }
  if (options.runScripts !== false) {
    executeScriptTags();
  }
  currentState = window.history.state;
  triggerEvent(EVENTS.CHANGE);
  return triggerEvent(EVENTS.UPDATE);
};

findNodes = function(body, selector) {
  return Array.prototype.slice.apply(body.querySelectorAll(selector));
};

findNodesMatchingKeys = function(body, keys) {
  var key, matchingNodes, _i, _len, _ref;

  matchingNodes = [];
  _ref = (Array.isArray(keys) ? keys : [keys]);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    key = _ref[_i];
    matchingNodes.push.apply(matchingNodes, findNodes(body, '[id^="' + key + ':"], [id="' + key + '"]'));
  }
  return matchingNodes;
};

swapNodes = function(targetBody, existingNodes, options) {
  var existingNode, nodeId, targetNode, _i, _len;

  for (_i = 0, _len = existingNodes.length; _i < _len; _i++) {
    existingNode = existingNodes[_i];
    if (!(nodeId = existingNode.getAttribute('id'))) {
      throw new Error("Turbolinks partial replace: turbolinks elements must have an id.");
    }
    if (targetNode = targetBody.querySelector('[id="' + nodeId + '"]')) {
      if (options.keep) {
        targetBody.ownerDocument.adoptNode(existingNode);
        targetNode.parentNode.replaceChild(existingNode, targetNode);
      } else {
        targetNode = targetNode.cloneNode(true);
        existingNode.parentNode.replaceChild(targetNode, existingNode);
      }
    }
  }
};

executeScriptTags = function() {
  var attr, copy, nextSibling, parentNode, script, scripts, _i, _j, _len, _len1, _ref, _ref1;

  scripts = document.body.querySelectorAll('script:not([data-turbolinks-eval="false"])');
  for (_i = 0, _len = scripts.length; _i < _len; _i++) {
    script = scripts[_i];
    if (!((_ref = script.type) === '' || _ref === 'text/javascript')) {
      continue;
    }
    copy = document.createElement('script');
    _ref1 = script.attributes;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      attr = _ref1[_j];
      copy.setAttribute(attr.name, attr.value);
    }
    if (!script.hasAttribute('async')) {
      copy.async = false;
    }
    copy.appendChild(document.createTextNode(script.innerHTML));
    parentNode = script.parentNode, nextSibling = script.nextSibling;
    parentNode.removeChild(script);
    parentNode.insertBefore(copy, nextSibling);
  }
};

removeNoscriptTags = function(node) {
  node.innerHTML = node.innerHTML.replace(/<noscript[\S\s]*?<\/noscript>/ig, '');
  return node;
};

setAutofocusElement = function() {
  var autofocusElement, list;

  autofocusElement = (list = document.querySelectorAll('input[autofocus], textarea[autofocus]'))[list.length - 1];
  if (autofocusElement && document.activeElement !== autofocusElement) {
    return autofocusElement.focus();
  }
};

reflectNewUrl = function(url) {
  if ((url = new ComponentUrl(url)).absolute !== referer) {
    return window.history.pushState({
      turbolinks: true,
      url: url.absolute
    }, '', url.absolute);
  }
};

reflectRedirectedUrl = function() {
  var location, preservedHash;

  if (location = xhr.getResponseHeader('X-XHR-Redirected-To')) {
    location = new ComponentUrl(location);
    preservedHash = location.hasNoHash() ? document.location.hash : '';
    return window.history.replaceState(window.history.state, '', location.href + preservedHash);
  }
};

crossOriginRedirect = function() {
  var redirect;

  if (((redirect = xhr.getResponseHeader('Location')) != null) && (new ComponentUrl(redirect)).crossOrigin()) {
    return redirect;
  }
};

rememberReferer = function() {
  return referer = document.location.href;
};

rememberCurrentUrl = function() {
  return window.history.replaceState({
    turbolinks: true,
    url: document.location.href
  }, '', document.location.href);
};

rememberCurrentState = function() {
  return currentState = window.history.state;
};

manuallyTriggerHashChangeForFirefox = function() {
  var url;

  if (navigator.userAgent.match(/Firefox/) && !(url = new ComponentUrl).hasNoHash()) {
    window.history.replaceState(currentState, '', url.withoutHash());
    return document.location.hash = url.hash;
  }
};

recallScrollPosition = function(page) {
  return window.scrollTo(page.positionX, page.positionY);
};

resetScrollPosition = function() {
  if (document.location.hash) {
    return document.location.href = document.location.href;
  } else {
    return window.scrollTo(0, 0);
  }
};

clone = function(original) {
  var copy, key, value;

  if ((original == null) || typeof original !== 'object') {
    return original;
  }
  copy = new original.constructor();
  for (key in original) {
    value = original[key];
    copy[key] = clone(value);
  }
  return copy;
};

popCookie = function(name) {
  var value, _ref;

  value = ((_ref = document.cookie.match(new RegExp(name + "=(\\w+)"))) != null ? _ref[1].toUpperCase() : void 0) || '';
  document.cookie = name + '=; expires=Thu, 01-Jan-70 00:00:01 GMT; path=/';
  return value;
};

uniqueId = function() {
  return new Date().getTime().toString(36);
};

triggerEvent = function(name, data) {
  var event;

  if (typeof Prototype !== 'undefined') {
    Event.fire(document, name, data, true);
  }
  event = document.createEvent('Events');
  if (data) {
    event.data = data;
  }
  event.initEvent(name, true, true);
  return document.dispatchEvent(event);
};

pageChangePrevented = function(url) {
  return !triggerEvent(EVENTS.BEFORE_CHANGE, {
    url: url
  });
};

processResponse = function() {
  var assetsChanged, clientOrServerError, doc, downloadingFile, extractTrackAssets, intersection, validContent;

  clientOrServerError = function() {
    var _ref;

    return (400 <= (_ref = xhr.status) && _ref < 600);
  };
  validContent = function() {
    var contentType;

    return ((contentType = xhr.getResponseHeader('Content-Type')) != null) && contentType.match(/^(?:text\/html|application\/xhtml\+xml|application\/xml)(?:;|$)/);
  };
  downloadingFile = function() {
    var disposition;

    return ((disposition = xhr.getResponseHeader('Content-Disposition')) != null) && disposition.match(/^attachment/);
  };
  extractTrackAssets = function(doc) {
    var node, _i, _len, _ref, _results;

    _ref = doc.querySelector('head').childNodes;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      if ((typeof node.getAttribute === "function" ? node.getAttribute('data-turbolinks-track') : void 0) != null) {
        _results.push(node.getAttribute('src') || node.getAttribute('href'));
      }
    }
    return _results;
  };
  assetsChanged = function(doc) {
    var fetchedAssets;

    loadedAssets || (loadedAssets = extractTrackAssets(document));
    fetchedAssets = extractTrackAssets(doc);
    return fetchedAssets.length !== loadedAssets.length || intersection(fetchedAssets, loadedAssets).length !== loadedAssets.length;
  };
  intersection = function(a, b) {
    var value, _i, _len, _ref, _results;

    if (a.length > b.length) {
      _ref = [b, a], a = _ref[0], b = _ref[1];
    }
    _results = [];
    for (_i = 0, _len = a.length; _i < _len; _i++) {
      value = a[_i];
      if (__indexOf.call(b, value) >= 0) {
        _results.push(value);
      }
    }
    return _results;
  };
  if (!clientOrServerError() && validContent() && !downloadingFile()) {
    doc = createDocument(xhr.responseText);
    if (doc && !assetsChanged(doc)) {
      return doc;
    }
  }
};

extractTitleAndBody = function(doc) {
  var title;

  title = doc.querySelector('title');
  return [title != null ? title.textContent : void 0, removeNoscriptTags(doc.querySelector('body')), CSRFToken.get(doc).token];
};

CSRFToken = {
  get: function(doc) {
    var tag;

    if (doc == null) {
      doc = document;
    }
    return {
      node: tag = doc.querySelector('meta[name="csrf-token"]'),
      token: tag != null ? typeof tag.getAttribute === "function" ? tag.getAttribute('content') : void 0 : void 0
    };
  },
  update: function(latest) {
    var current;

    current = this.get();
    if ((current.token != null) && (latest != null) && current.token !== latest) {
      return current.node.setAttribute('content', latest);
    }
  }
};

createDocument = function(html) {
  var doc;

  doc = document.documentElement.cloneNode();
  doc.innerHTML = html;
  doc.head = doc.querySelector('head');
  doc.body = doc.querySelector('body');
  return doc;
};

ComponentUrl = (function() {
  function ComponentUrl(original) {
    this.original = original != null ? original : document.location.href;
    if (this.original.constructor === ComponentUrl) {
      return this.original;
    }
    this._parse();
  }

  ComponentUrl.prototype.withoutHash = function() {
    return this.href.replace(this.hash, '').replace('#', '');
  };

  ComponentUrl.prototype.withoutHashForIE10compatibility = function() {
    return this.withoutHash();
  };

  ComponentUrl.prototype.hasNoHash = function() {
    return this.hash.length === 0;
  };

  ComponentUrl.prototype.crossOrigin = function() {
    return this.origin !== (new ComponentUrl).origin;
  };

  ComponentUrl.prototype.formatForXHR = function(options) {
    if (options == null) {
      options = {};
    }
    return (options.cache ? this : this.withAntiCacheParam()).withoutHashForIE10compatibility();
  };

  ComponentUrl.prototype.withAntiCacheParam = function() {
    return new ComponentUrl(/([?&])_=[^&]*/.test(this.absolute) ? this.absolute.replace(/([?&])_=[^&]*/, "$1_=" + (uniqueId())) : new ComponentUrl(this.absolute + (/\?/.test(this.absolute) ? "&" : "?") + ("_=" + (uniqueId()))));
  };

  ComponentUrl.prototype._parse = function() {
    var _ref, _ref1;

    ((_ref = this.link) != null ? _ref : this.link = document.createElement('a')).href = this.original;
    _ref1 = this.link, this.href = _ref1.href, this.protocol = _ref1.protocol, this.host = _ref1.host, this.hostname = _ref1.hostname, this.port = _ref1.port, this.pathname = _ref1.pathname, this.search = _ref1.search, this.hash = _ref1.hash;
    this.origin = [this.protocol, '//', this.hostname].join('');
    if (this.port.length !== 0) {
      this.origin += ":" + this.port;
    }
    this.relative = [this.pathname, this.search, this.hash].join('');
    return this.absolute = this.href;
  };

  return ComponentUrl;

})();

Link = (function(_super) {
  __extends(Link, _super);

  Link.HTML_EXTENSIONS = ['html'];

  Link.allowExtensions = function() {
    var extension, extensions, _i, _len;

    extensions = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (_i = 0, _len = extensions.length; _i < _len; _i++) {
      extension = extensions[_i];
      Link.HTML_EXTENSIONS.push(extension);
    }
    return Link.HTML_EXTENSIONS;
  };

  function Link(link) {
    this.link = link;
    if (this.link.constructor === Link) {
      return this.link;
    }
    this.original = this.link.href;
    this.originalElement = this.link;
    this.link = this.link.cloneNode(false);
    Link.__super__.constructor.apply(this, arguments);
  }

  Link.prototype.shouldIgnore = function() {
    return this.crossOrigin() || this._anchored() || this._nonHtml() || this._optOut() || this._target();
  };

  Link.prototype._anchored = function() {
    return (this.hash.length > 0 || this.href.charAt(this.href.length - 1) === '#') && (this.withoutHash() === (new ComponentUrl).withoutHash());
  };

  Link.prototype._nonHtml = function() {
    return this.pathname.match(/\.[a-z]+$/g) && !this.pathname.match(new RegExp("\\.(?:" + (Link.HTML_EXTENSIONS.join('|')) + ")?$", 'g'));
  };

  Link.prototype._optOut = function() {
    var ignore, link;

    link = this.originalElement;
    while (!(ignore || link === document)) {
      ignore = link.getAttribute('data-no-turbolink') != null;
      link = link.parentNode;
    }
    return ignore;
  };

  Link.prototype._target = function() {
    return this.link.target.length !== 0;
  };

  return Link;

})(ComponentUrl);

Click = (function() {
  Click.installHandlerLast = function(event) {
    if (!event.defaultPrevented) {
      document.removeEventListener('click', Click.handle, false);
      return document.addEventListener('click', Click.handle, false);
    }
  };

  Click.handle = function(event) {
    return new Click(event);
  };

  function Click(event) {
    this.event = event;
    if (this.event.defaultPrevented) {
      return;
    }
    this._extractLink();
    if (this._validForTurbolinks()) {
      if (!pageChangePrevented(this.link.absolute)) {
        visit(this.link.href);
      }
      this.event.preventDefault();
    }
  }

  Click.prototype._extractLink = function() {
    var link;

    link = this.event.target;
    while (!(!link.parentNode || link.nodeName === 'A')) {
      link = link.parentNode;
    }
    if (link.nodeName === 'A' && link.href.length !== 0) {
      return this.link = new Link(link);
    }
  };

  Click.prototype._validForTurbolinks = function() {
    return (this.link != null) && !(this.link.shouldIgnore() || this._nonStandardClick());
  };

  Click.prototype._nonStandardClick = function() {
    return this.event.which > 1 || this.event.metaKey || this.event.ctrlKey || this.event.shiftKey || this.event.altKey;
  };

  return Click;

})();

ProgressBar = (function() {
  var className, originalOpacity;

  className = 'turbolinks-progress-bar';

  originalOpacity = 0.99;

  ProgressBar.enable = function() {
    return progressBar != null ? progressBar : progressBar = new ProgressBar('html');
  };

  ProgressBar.disable = function() {
    if (progressBar != null) {
      progressBar.uninstall();
    }
    return progressBar = null;
  };

  function ProgressBar(elementSelector) {
    this.elementSelector = elementSelector;
    this._trickle = __bind(this._trickle, this);
    this._reset = __bind(this._reset, this);
    this.value = 0;
    this.content = '';
    this.speed = 300;
    this.opacity = originalOpacity;
    this.install();
  }

  ProgressBar.prototype.install = function() {
    this.element = document.querySelector(this.elementSelector);
    this.element.classList.add(className);
    this.styleElement = document.createElement('style');
    document.head.appendChild(this.styleElement);
    return this._updateStyle();
  };

  ProgressBar.prototype.uninstall = function() {
    this.element.classList.remove(className);
    return document.head.removeChild(this.styleElement);
  };

  ProgressBar.prototype.start = function() {
    if (this.value > 0) {
      this._reset();
      this._reflow();
    }
    return this.advanceTo(5);
  };

  ProgressBar.prototype.advanceTo = function(value) {
    var _ref;

    if ((value > (_ref = this.value) && _ref <= 100)) {
      this.value = value;
      this._updateStyle();
      if (this.value === 100) {
        return this._stopTrickle();
      } else if (this.value > 0) {
        return this._startTrickle();
      }
    }
  };

  ProgressBar.prototype.done = function() {
    if (this.value > 0) {
      this.advanceTo(100);
      return this._finish();
    }
  };

  ProgressBar.prototype._finish = function() {
    var _this = this;

    this.fadeTimer = setTimeout(function() {
      _this.opacity = 0;
      return _this._updateStyle();
    }, this.speed / 2);
    return this.resetTimer = setTimeout(this._reset, this.speed);
  };

  ProgressBar.prototype._reflow = function() {
    return this.element.offsetHeight;
  };

  ProgressBar.prototype._reset = function() {
    var _this = this;

    this._stopTimers();
    this.value = 0;
    this.opacity = originalOpacity;
    return this._withSpeed(0, function() {
      return _this._updateStyle(true);
    });
  };

  ProgressBar.prototype._stopTimers = function() {
    this._stopTrickle();
    clearTimeout(this.fadeTimer);
    return clearTimeout(this.resetTimer);
  };

  ProgressBar.prototype._startTrickle = function() {
    if (this.trickleTimer) {
      return;
    }
    return this.trickleTimer = setTimeout(this._trickle, this.speed);
  };

  ProgressBar.prototype._stopTrickle = function() {
    clearTimeout(this.trickleTimer);
    return delete this.trickleTimer;
  };

  ProgressBar.prototype._trickle = function() {
    this.advanceTo(this.value + Math.random() / 2);
    return this.trickleTimer = setTimeout(this._trickle, this.speed);
  };

  ProgressBar.prototype._withSpeed = function(speed, fn) {
    var originalSpeed, result;

    originalSpeed = this.speed;
    this.speed = speed;
    result = fn();
    this.speed = originalSpeed;
    return result;
  };

  ProgressBar.prototype._updateStyle = function(forceRepaint) {
    if (forceRepaint == null) {
      forceRepaint = false;
    }
    if (forceRepaint) {
      this._changeContentToForceRepaint();
    }
    return this.styleElement.textContent = this._createCSSRule();
  };

  ProgressBar.prototype._changeContentToForceRepaint = function() {
    return this.content = this.content === '' ? ' ' : '';
  };

  ProgressBar.prototype._createCSSRule = function() {
    return "" + this.elementSelector + "." + className + "::before {\n  content: '" + this.content + "';\n  position: fixed;\n  top: 0;\n  left: 0;\n  z-index: 2000;\n  background-color: #0076ff;\n  height: 3px;\n  opacity: " + this.opacity + ";\n  width: " + this.value + "%;\n  transition: width " + this.speed + "ms ease-out, opacity " + (this.speed / 2) + "ms ease-in;\n  transform: translate3d(0,0,0);\n}";
  };

  return ProgressBar;

})();

ProgressBarAPI = {
  enable: ProgressBar.enable,
  disable: ProgressBar.disable,
  start: function() {
    return ProgressBar.enable().start();
  },
  advanceTo: function(value) {
    return progressBar != null ? progressBar.advanceTo(value) : void 0;
  },
  done: function() {
    return progressBar != null ? progressBar.done() : void 0;
  }
};

bypassOnLoadPopstate = function(fn) {
  return setTimeout(fn, 500);
};

installDocumentReadyPageEventTriggers = function() {
  return document.addEventListener('DOMContentLoaded', (function() {
    triggerEvent(EVENTS.CHANGE);
    return triggerEvent(EVENTS.UPDATE);
  }), true);
};

installJqueryAjaxSuccessPageUpdateTrigger = function() {
  if (typeof jQuery !== 'undefined') {
    return jQuery(document).on('ajaxSuccess', function(event, xhr, settings) {
      if (!jQuery.trim(xhr.responseText)) {
        return;
      }
      return triggerEvent(EVENTS.UPDATE);
    });
  }
};

installHistoryChangeHandler = function(event) {
  var cachedPage, _ref;

  if ((_ref = event.state) != null ? _ref.turbolinks : void 0) {
    if (cachedPage = pageCache[(new ComponentUrl(event.state.url)).absolute]) {
      cacheCurrentPage();
      return fetchHistory(cachedPage);
    } else {
      return visit(event.target.location.href);
    }
  }
};

initializeTurbolinks = function() {
  rememberCurrentUrl();
  rememberCurrentState();
  ProgressBar.enable();
  document.addEventListener('click', Click.installHandlerLast, true);
  window.addEventListener('hashchange', function(event) {
    rememberCurrentUrl();
    return rememberCurrentState();
  }, false);
  return bypassOnLoadPopstate(function() {
    return window.addEventListener('popstate', installHistoryChangeHandler, false);
  });
};

historyStateIsDefined = window.history.state !== void 0 || navigator.userAgent.match(/Firefox\/2[6|7]/);

browserSupportsPushState = window.history && window.history.pushState && window.history.replaceState && historyStateIsDefined;

browserIsntBuggy = !navigator.userAgent.match(/CriOS\//);

requestMethodIsSafe = (_ref = popCookie('request_method')) === 'GET' || _ref === '';

browserSupportsTurbolinks = browserSupportsPushState && browserIsntBuggy && requestMethodIsSafe;

browserSupportsCustomEvents = document.addEventListener && document.createEvent;

if (browserSupportsCustomEvents) {
  installDocumentReadyPageEventTriggers();
  installJqueryAjaxSuccessPageUpdateTrigger();
}

if (browserSupportsTurbolinks) {
  visit = fetch;
  initializeTurbolinks();
} else {
  visit = function(url) {
    return document.location.href = url;
  };
}

this.Turbolinks = {
  visit: visit,
  replace: replace,
  pagesCached: pagesCached,
  cacheCurrentPage: cacheCurrentPage,
  enableTransitionCache: enableTransitionCache,
  disableRequestCaching: disableRequestCaching,
  ProgressBar: ProgressBarAPI,
  allowLinkExtensions: Link.allowExtensions,
  supported: browserSupportsTurbolinks,
  EVENTS: clone(EVENTS)
};