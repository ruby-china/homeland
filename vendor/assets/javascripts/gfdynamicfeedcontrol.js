/**
 * Copyright (c) 2008 Google Inc.
 *
 * You are free to copy and use this sample.
 * License can be found here: http://code.google.com/apis/ajaxsearch/faq/#license
*/

/**
 * @fileoverview A feed gadget based on the AJAX Feed API.
 * @author dcollison@google.com (Derek Collison)
 */

/**
 * GFdynamicFeedControl
 * @param {String} feed The feed URL.
 * @param {String|Object} container Either the id string or the element itself.
 * @param {Object} options Options map.
 * @constructor
 */

function GFdynamicFeedControl(feedUrls, container, options) {
  // node elements.
  this.nodes = {};
  this.collapseElements = [];
  
  // the feeds.
  this.feeds = [];
  this.results = [];

  if (typeof feedUrls == 'string') {
    this.feeds.push({url:feedUrls});
  } else if (typeof feedUrls == 'object') {
    for (var i=0; i<feedUrls.length; i++) {
      var entry = feedUrls[i];
      var o = {};
      var feedUrl;
      if (typeof entry == 'string') {
        o.url = feedUrls[i];
      } else if (typeof entry == 'object') {
        o = feedUrls[i];
	if (o && o.title) {
	  var s = o.title;
	  o.title = s.replace(/</g,'&lt;').replace(/>/g, '&gt;');
	}
      }
      this.feeds.push(o);
    }
  }

  if (typeof container == "string") {
    container = document.getElementById(container);
  }
  this.parseOptions_(options);
  this.setup_(container);
}

/*
 * Default time in milliseconds for the feed to be reloaded.
 * @type Number
 */
GFdynamicFeedControl.DEFAULT_NUM_RESULTS = 4;
/*
 * Default time in milliseconds for the feed to be reloaded.
 * @type Number
 */
GFdynamicFeedControl.DEFAULT_FEED_CYCLE_TIME = 1800000;
/*
 * Default display time in milliseconds for each entry.
 * @type Number
 */
GFdynamicFeedControl.DEFAULT_DISPLAY_TIME = 5000;
/*
 * Default fadeout transition time in milliseconds for each entry.
 * @type Number
 */
GFdynamicFeedControl.DEFAULT_FADEOUT_TIME = 1000;
/*
 * Default time between transition steps in milliseconds
 * @type Number
 */
GFdynamicFeedControl.DEFAULT_TRANSISTION_STEP = 40;
/*
 * Default hover time in milliseconds for each entry.
 * @type Number
 */
GFdynamicFeedControl.DEFAULT_HOVER_TIME = 100;

/**
 * Setup default option map and apply overrides from constructor.
 * @param {Object} options Options map.
 * @private
 */
GFdynamicFeedControl.prototype.parseOptions_ = function(options) {
  // Default Options
  // TODO(dcollison) - implement Feed Cycle.
  this.options = {
    numResults : GFdynamicFeedControl.DEFAULT_NUM_RESULTS,
    feedCycleTime : GFdynamicFeedControl.DEFAULT_FEED_CYCLE_TIME,
    linkTarget : google.feeds.LINK_TARGET_BLANK,
    displayTime : GFdynamicFeedControl.DEFAULT_DISPLAY_TIME,
    transitionTime : GFdynamicFeedControl.DEFAULT_TRANSISTION_TIME,
    transitionStep : GFdynamicFeedControl.DEFAULT_TRANSISTION_STEP,
    fadeOutTime: GFdynamicFeedControl.DEFAULT_FADEOUT_TIME,
    scrollOnFadeOut : true,
    pauseOnHover : true,
    hoverTime : GFdynamicFeedControl.DEFAULT_HOVER_TIME,
    autoCleanup : true,
    transitionCallback : null,
    feedTransitionCallback : null,
    feedLoadCallback : null,
    collapseable : false,
    sortByDate : false,
    horizontal : false,
    stacked : false,
    title : null
  };

  if (options) {
    for (var o in this.options) {
      if (typeof options[o] != 'undefined') {
        this.options[o] = options[o];
      }
    }
  }
  
  // Cant be collapseable unless stacked
  if(!this.options.stacked) {
    this.options.collapseable = false;
  }
  
  // Override strange/bad options
  this.options.displayTime = Math.max(200, this.options.displayTime);
  this.options.fadeOutTime = Math.max(0, this.options.fadeOutTime);

  // Calculated
  var ts = this.options.fadeOutTime / this.options.transitionStep;
  this.fadeOutDelta = Math.min(1, (1.0/ts));

  // Flag to start
  this.started = false;
};

/**
 * Basic setup.
 * @private
 */
GFdynamicFeedControl.prototype.setup_ = function(container) {
  if (container == null) return;
  this.nodes.container = container;

  // Browser fun.
  if (window.ActiveXObject) {
    this.ie = this[window.XMLHttpRequest ? 'ie7' : 'ie6'] = true;
  } else if (document.childNodes && !document.all && !navigator.taintEnabled) {
    this.safari = true;
  } else if (document.getBoxObjectFor != null) {
    this.gecko = true;
  }
  // The feedControl instance for generating entry HTML.
  this.feedControl = new google.feeds.FeedControl();
  this.feedControl.setLinkTarget(this.options.linkTarget);

  // The feeds
  this.expected = this.feeds.length;
  this.errors = 0;

  for (var i = 0; i < this.feeds.length; i++) {
    var feed = new google.feeds.Feed(this.feeds[i].url);
    feed.setResultFormat(google.feeds.Feed.JSON_FORMAT);
    feed.setNumEntries(this.options.numResults);
    feed.load(this.bind_(this.feedLoaded_, i));
  }
};

/**
 * Helper method to bind this instance correctly.
 * @param {Object} method function/method to bind.
 * @return {Function}
 * @private
 */
GFdynamicFeedControl.prototype.bind_ = function(method) {
  var self = this;
  var opt_args = [].slice.call(arguments, 1);
  return function() {
    var args = opt_args.concat([].slice.call(arguments));
    return method.apply(self, args);
  }
};

/**
 * Callback associated with the AJAX Feed api after load.
 * @param {Object} result Loaded result.
 * @private
 */
GFdynamicFeedControl.prototype.feedLoaded_ = function(index, result) {
  if (this.options.feedLoadCallback) {
    this.options.feedLoadCallback(result);
  }
  if (result.error) {
    // Ignore failed feeds for the most part.
    // The user has control through the feedLoadCallback above
    // if they choose to do something more createive.
    // Only complain if we can't load anything.
    if (++this.errors >= this.expected) {
      this.nodes.container.innerHTML = 'Feed' + ((this.expected > 1)?'s ':' ') +
                                       'could not be loaded.';
    }
    return;
  }
  // Override of title option.
  if (this.feeds[index].title) {
    result.feed.title = this.feeds[index].title;
  }
  this.results.push(result);

  if (!this.started) {
    this.createSubContainers_();
    this.displayResult_(0);
  } else if (!this.options.horizontal && this.options.stacked) {
    this.addResult_(this.results.length-1);
  }
};

/**
 * Insert blog in correct place
 * @private
 */
GFdynamicFeedControl.prototype.sortByDate_ = function(resultIndex, newTitle,
                                                      newList) {
  // if sorting by date, insert it into the correct spot
  var newEntryDate = this.results[resultIndex].feed.entries[0].publishedDate;
  var newEntryDateMS = Date.parse(newEntryDate);
  var insertIndex = null;

  for (var i = 0; i < this.results.length; i++) {
    var mostRecentPost = this.results[i].feed.entries[0].publishedDate;
    var mostRecentPostMS = Date.parse(mostRecentPost);
    if(newEntryDateMS > mostRecentPostMS) {
      insertIndex = i;
      break;
    }
  }

  // If it's most stale blog, just append as usual
  if(insertIndex == null) {
    this.nodes.root.appendChild(newTitle);
    this.nodes.root.appendChild(newList);
    this.createListEntries_(resultIndex, newList);
    return;
  }

  // If it is fresher than a blog, insert to correct position
  var insertBeforeIndex = 2 + (insertIndex * 2);
  var swapToIndex = insertBeforeIndex + 2;
  var tempSwap = null;
  var myResultIndex = resultIndex + 1;

  var sectionsToChange = this.nodes.root.childNodes;
  var nodeToInsertBefore = sectionsToChange[insertBeforeIndex];

  this.nodes.root.insertBefore(newTitle, nodeToInsertBefore);
  this.nodes.root.insertBefore(newList, nodeToInsertBefore);

  this.results.splice(insertIndex, 0, this.results[resultIndex]);
  this.results.splice(myResultIndex, 1);
  
  var nodesToChangeClick = sectionsToChange[swapToIndex].nextSibling.childNodes;
  
  this.createListEntries_(insertIndex, newList);

  // Keep freshest blog open first
  if(insertIndex == 0) {
    this.displayResult_(0);
  }

  insertIndex += 1;
  // Reset all of the onmousehover listeners to highlight corect index
  for (var i = swapToIndex; i < sectionsToChange.length; i += 2) {
    var nodesToChangeClick = sectionsToChange[i].nextSibling.childNodes;
    for (var j=0; j < nodesToChangeClick.length; j++) {
      nodesToChangeClick[j].onmouseover = this.bind_(this.listMouseOver_, 
                                                     insertIndex, j);
      nodesToChangeClick[j].onmouseout = this.bind_(this.listMouseOut_, 
                                                    insertIndex, j);
    }
    insertIndex++;
  }
};

/**
 * Setup to display the Result for stacked mode
 * @private
 */
GFdynamicFeedControl.prototype.addResult_ = function(resultIndex) {
  var result = this.results[resultIndex];
  var newTitle = this.createDiv_('gfg-subtitle');
  this.setTitle_(result.feed, newTitle);
  var newList = this.createDiv_('gfg-list');

  // add a collapseable button
  if(this.options.collapseable) {
    var collapseLink = document.createElement('div');
    newList.style.display = 'none';
    collapseLink.className = 'gfg-collapse-closed';
    newTitle.appendChild(collapseLink);
    collapseLink.onclick = this.toggleCollapse(this, newList, collapseLink);
    this.collapseElements.push({
      list : newList,
      collapse : collapseLink
    });
  }


  var clearFloat = document.createElement('div');
  clearFloat.className = 'clearFloat';
  newTitle.appendChild(clearFloat);

  // If not sorting by date, add them as usual
  if(!this.options.sortByDate) {
    this.nodes.root.appendChild(newTitle);
    this.nodes.root.appendChild(newList);
    this.createListEntries_(resultIndex, newList);
  } else {
    this.sortByDate_(resultIndex, newTitle, newList);
  }
  
};

/**
 * Setup to display the Result
 * @private
 */
GFdynamicFeedControl.prototype.displayResult_ = function(resultIndex) {
  this.resultIndex = resultIndex;
  var result = this.results[resultIndex];
  if (this.options.feedTransitionCallback) {
    this.options.feedTransitionCallback(result);
  }
  if (this.options.title) {
    this.setPlainTitle_(this.options.title);
  } else {
    this.setTitle_(result.feed);
  }
  this.clearNode_(this.nodes.entry);

  if (this.started && !this.options.horizontal && this.options.stacked) {
    this.entries = result.feed.entries;
  } else {
    this.createListEntries_(resultIndex, this.nodes.list);
  }
  this.displayEntries_();
}

/**
 * Set the Title to just plaintext
 * @private
 */
GFdynamicFeedControl.prototype.setPlainTitle_ = function(title, opt_element) {
  var el = opt_element || this.nodes.title;
  el.innerHTML = title;
}

/**
 * Set the Title
 * @private
 */
GFdynamicFeedControl.prototype.setTitle_ = function(resultFeed, opt_element) {
  var el = opt_element || this.nodes.title;
  this.clearNode_(el);
  var link = document.createElement('a');
  link.target = google.feeds.LINK_TARGET_BLANK;
  link.href = resultFeed.link;
  link.className = 'gfg-collapse-href';
  link.innerHTML = resultFeed.title;
  el.appendChild(link);
}

GFdynamicFeedControl.prototype.toggleCollapse = function(feedControl, 
                                                         listReference, 
                                                         collapseLink) {
  return function() {
    var els = feedControl.collapseElements;
    for (var i=0; i < els.length; i++) {
      var el = els[i];
      el.list.style.display = 'none';
      el.collapse.className = 'gfg-collapse-closed';
    }
    listReference.style.display = 'block';
    collapseLink.className = 'gfg-collapse-open';
  }
}

/**
 * Create the list Entries
 * @private
 */
GFdynamicFeedControl.prototype.createListEntries_ = function(resultIndex, node) {
  var entries = this.results[resultIndex].feed.entries;
  this.clearNode_(node);
  for (var i = 0; i < entries.length; i++) {
    this.feedControl.createHtml(entries[i]);
    var className = 'gfg-listentry ';
    className += (i%2)?'gfg-listentry-even':'gfg-listentry-odd';
    var listEntry = this.createDiv_(className);
    var link = this.createLink_(entries[i].link,
                                entries[i].title,
                                this.options.linkTarget);
    listEntry.appendChild(link);
    if (this.options.pauseOnHover) {
      listEntry.onmouseover = this.bind_(this.listMouseOver_, resultIndex, i);
      listEntry.onmouseout = this.bind_(this.listMouseOut_, resultIndex, i);
    }
    entries[i].listEntry = listEntry;
    node.appendChild(listEntry);
  }
  if (node == this.nodes.list) {
    this.entries = entries;
  }
}

/**
 * Begin to display the entries.
 * @private
 */
GFdynamicFeedControl.prototype.displayEntries_ = function() {
  this.entryIndex = 0;
  this.displayCurrentEntry_();
  this.setDisplayTimer_();
  this.started = true;
}

/**
 * Display next entry.
 * @private
 */
GFdynamicFeedControl.prototype.displayNextEntry_ = function() {
  // Check to see if we have been orphaned and need to cleanup..
  if (this.options.autoCleanup && this.isOrphaned_()) {
      this.cleanup_();
      return;
  }

  if (++this.entryIndex >= this.entries.length) {
    // End of list, see if we should rotate feeds..
    if (this.results.length > 1) {
      if (++this.resultIndex >= this.results.length) {
        this.resultIndex = 0;
      }
      this.displayResult_(this.resultIndex);
      return;
    } else {
      this.entryIndex = 0;
    }
  }

  if (this.options.transitionCallback) {
    this.options.transitionCallback(this.entries[this.entryIndex]);
  }
  this.displayCurrentEntry_();
  this.setDisplayTimer_();
}

/**
 * Display current entry.
 * @private
 */
GFdynamicFeedControl.prototype.displayCurrentEntry_ = function() {
  this.clearNode_(this.nodes.entry);
  this.current = this.entries[this.entryIndex].html;
  this.current.style.top = '0px';
  this.nodes.entry.appendChild(this.current);
  this.createOverlay_();
  
  // Expand the blog who's post is being displayed
  if(this.options.collapseable) {
    var feedTitle = null;
    
    for (var i=0; i < this.results.length; i++) {
      if(this.results[i].feed.entries == this.entries) {
        feedTitle = this.results[i].feed.title;
      }
    }

    var els = this.collapseElements;

    for (var i=0; i < els.length; i++) {
      var el = els[i];
      var divfeedTitle = el.collapse.previousSibling.innerHTML;
      var expandClicker = el.collapse;
      if(feedTitle == divfeedTitle) {
        if(this.ie) {
          expandClicker.click();
        } else {
          expandClicker.onclick();
        }

      }
    }
  }
  
  if (this.currentList) {
    var className = 'gfg-listentry ';
    className += (this.currentListIndex%2)?
        'gfg-listentry-even':'gfg-listentry-odd';
    this.currentList.className = className;
  }
  this.currentList = this.entries[this.entryIndex].listEntry;
  this.currentListIndex = this.entryIndex;
  var className = 'gfg-listentry gfg-listentry-highlight ';
  className += (this.currentListIndex%2)?
       'gfg-listentry-even':'gfg-listentry-odd';
  this.currentList.className = className;
}

/**
 * Simulated mouse hover events for list entries.
 * @private
 */
GFdynamicFeedControl.prototype.listMouseHover_ = function(resultIndex,
                                                          listIndex) {
  var result = this.results[resultIndex];
  var listEntry = result.feed.entries[listIndex].listEntry;
  listEntry.selectTimer = null;
  this.clearTransitionTimer_();
  this.clearDisplayTimer_();
  this.resultIndex = resultIndex;
  this.entries = result.feed.entries;
  this.entryIndex = listIndex;
  this.displayCurrentEntry_();
}

/**
 * Mouse over events for list entries.
 * @private
 */
GFdynamicFeedControl.prototype.listMouseOver_ = function(resultIndex,
                                                         listIndex) {
  var result = this.results[resultIndex];
  var listEntry = result.feed.entries[listIndex].listEntry;
  var cb = this.bind_(this.listMouseHover_, resultIndex, listIndex);
  listEntry.selectTimer = setTimeout(cb, this.options.hoverTime);
}

/**
 * Mouse out events for list entries.
 * @private
 */
GFdynamicFeedControl.prototype.listMouseOut_ = function(resultIndex, listIndex) {
  var result = this.results[resultIndex];
  var listEntry = result.feed.entries[listIndex].listEntry;
  if (listEntry.selectTimer) {
    clearTimeout(listEntry.selectTimer);
    listEntry.selectTimer = null;
  } else {
    this.setDisplayTimer_();
  }
}

/**
 * Mouse over events for main entry.
 * @private
 */
GFdynamicFeedControl.prototype.entryMouseOver_ = function(e) {
  this.clearDisplayTimer_();
  if (this.transitionTimer) {
    this.clearTransitionTimer_();
    this.displayCurrentEntry_();
  }
}

/**
 * Mouse out events for main entry.
 * @private
 */
GFdynamicFeedControl.prototype.entryMouseOut_ = function(e) {
  this.setDisplayTimer_();
}

/**
 * Create the overlay div. This hack is for IE and transparency effects.
 * @private
 */
GFdynamicFeedControl.prototype.createOverlay_ = function() {
  if (this.current == null) return;
  // Create div lazily and hold on to it..
  if (this.overlay == null) {
    var overlay = this.createDiv_('gfg-entry');
    overlay.style.position = 'absolute';
    overlay.style.top = '0px';
    overlay.style.left = '0px';
    this.overlay = overlay;
  }
  this.setOpacity_(this.overlay, 0);
  this.nodes.entry.appendChild(this.overlay);
}

/**
 * Sets the display timer.
 * @private
 */
GFdynamicFeedControl.prototype.setDisplayTimer_ = function() {
  if (this.displayTimer) {
    this.clearDisplayTimer_();
  }
  var cb = this.bind_(this.setFadeOutTimer_);
  this.displayTimer = setTimeout(cb, this.options.displayTime);
};

/**
 * Class helper method for the time now in milliseconds
 * @private
 */
GFdynamicFeedControl.timeNow = function() {
  var d = new Date();
  return d.getTime();
};

/**
 * Transition animation for fadeout. Cleanup when finished.
 * @private
 */
GFdynamicFeedControl.prototype.fadeOutEntry_ = function() {
  if (this.overlay) {
    var delta = this.fadeOutDelta;
    var ts = this.options.transitionStep;
    var now = GFdynamicFeedControl.timeNow();
    var tick = now - this.lastTick;
    this.lastTick = now;
    delta *= (tick/ts);

    var op = this.overlay.opacity + delta;
    // Overlay opacity
    this.setOpacity_(this.overlay, op);
    // Scroll down
    if (this.options.scrollOnFadeOut && (op > .5)) {
      var r = (op-.5)*2;
      var newTop = Math.round(this.current.offsetHeight * r);
      this.current.style.top = newTop + 'px';
    }
    if (op < 1) return;
  }
  // Finished.
  this.clearTransitionTimer_();
  this.displayNextEntry_();
};

/**
 * Sets the transition timer for fadeout.
 * @private
 */
GFdynamicFeedControl.prototype.setFadeOutTimer_ = function() {
  this.clearTransitionTimer_();
  this.lastTick = GFdynamicFeedControl.timeNow();
  var cb = this.bind_(this.fadeOutEntry_);
  this.transitionTimer = setInterval(cb, this.options.transitionStep);
};

/**
 * Clear the transition timer. Used to prevent leaks.
 * @private
 */
GFdynamicFeedControl.prototype.clearTransitionTimer_ = function() {
  if (this.transitionTimer) {
    clearInterval(this.transitionTimer);
    this.transitionTimer = null;
  }
};

/**
 * Clear the display timer.
 * @private
 */
GFdynamicFeedControl.prototype.clearDisplayTimer_ = function() {
  if (this.displayTimer) {
    clearTimeout(this.displayTimer);
    this.displayTimer = null;
  }
};

/**
 * Setup our own subcontainer to the user supplied container.
 * @private
 */
GFdynamicFeedControl.prototype.createSubContainers_ = function() {
  var nodes = this.nodes;
  var container = this.nodes.container;

  this.clearNode_(container);
  if (this.options.horizontal) {
    container = this.createDiv_('gfg-horizontal-container');
    nodes.root = this.createDiv_('gfg-horizontal-root');
    this.nodes.container.appendChild(container);
  } else {
    nodes.root = this.createDiv_('gfg-root');
  }
  nodes.title = this.createDiv_('gfg-title');
  nodes.entry = this.createDiv_('gfg-entry');
  nodes.list = this.createDiv_('gfg-list');
  nodes.root.appendChild(nodes.title);
  nodes.root.appendChild(nodes.entry);

  if (!this.options.horizontal && this.options.stacked) {
    var newTitle = this.createDiv_('gfg-subtitle');
    nodes.root.appendChild(newTitle);
    this.setTitle_(this.results[0].feed, newTitle);
    
    if(this.options.collapseable) {
      var collapseLink = document.createElement('div');
      collapseLink.className = 'gfg-collapse-open';
      newTitle.appendChild(collapseLink);
      collapseLink.onclick = this.toggleCollapse(this, nodes.list, collapseLink);
      this.collapseElements.push({
        list : nodes.list,
        collapse : collapseLink
      });
      nodes.list.style.display = 'block';
    }
    
    var clearFloat = document.createElement('div');
    clearFloat.className = 'clearFloat';
    newTitle.appendChild(clearFloat);
  }
  
  nodes.root.appendChild(nodes.list);
  container.appendChild(nodes.root);

  if (this.options.pauseOnHover) {
    nodes.entry.onmouseover = this.bind_(this.entryMouseOver_);
    nodes.entry.onmouseout = this.bind_(this.entryMouseOut_);
  }

  // Add Branding.
  if (this.options.horizontal) {
    nodes.branding = this.createDiv_('gfg-branding');
    google.feeds.getBranding(nodes.branding, google.feeds.VERTICAL_BRANDING);
    container.appendChild(nodes.branding);
  }
};

/**
 * Helper method to properly clear a node and its children.
 * @param {Object} node Node to clear.
 * @private
 */
GFdynamicFeedControl.prototype.clearNode_ = function(node) {
  if (node == null) return;
  var child;
  while ((child = node.firstChild)) {
    node.removeChild(child);
  }
};

/**
 * Helper method to create a div with optional class and text.
 * @param {String} opt_className Optional className for the div.
 * @param {String} opt_text Optional text for the innerHTML.
 * @private
 */
GFdynamicFeedControl.prototype.createDiv_ = function(opt_className, opt_text) {
  var el = document.createElement("div");
  if (opt_text) {
    el.innerHTML = opt_text;
  }
  if (opt_className) { el.className = opt_className; }
  return el;
};

/**
 * Helper method to create a link with href and text.
 * @param {String} href Href URL
 * @param {String} text text for the link.
 * @param {String} opt_target Optional link target.
 * @private
 */
GFdynamicFeedControl.prototype.createLink_ = function(href, text, opt_target) {
  var link = document.createElement('a');
  link.href = href;
  link.innerHTML = text;
  if (opt_target) {
    link.target = opt_target;
  }
  return link;
};

/**
 * Cleanup results on being orphaned.
 * @private
 */
GFdynamicFeedControl.prototype.clearResults_ = function() {
  for (var i=0; i < this.results.length; i++) {
    var result = this.results[i];
    var entries = result.feed.entries;
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i];
      entry.html = null;
      entry.listEntry.onmouseover = null;
      entry.listEntry.onmouseout = null;
      if (entry.listEntry.selectTimer) {
        clearTimeout(entry.listEntry.selectTimer);
        entry.listEntry.selectTimer = null;
      }
      entry.listEntry = null;
    }
  }
}

/**
 * Check for being orphaned.
 * @private
 */
GFdynamicFeedControl.prototype.isOrphaned_ = function() {
  var root = this.nodes.root;
  var orphaned = false;
  if (!root || !root.parentNode) {
    orphaned = true;
  } else if (this.options.horizontal && !root.parentNode.parentNode) {
    orphaned = true;
  }
  return orphaned;
}

/**
 * Cleanup on being orphaned.
 * @private
 */
GFdynamicFeedControl.prototype.cleanup_ = function() {
  this.started = false;
  // Timer Events.
  this.clearDisplayTimer_();
  this.clearTransitionTimer_();
  // Structures
  this.clearResults_();
  // Nodes
  this.clearNode_(this.nodes.root);
  this.nodes.container = null;
}

/**
 * Helper method to set opacity for nodes.. Also takes into account
 * visibility in general.
 * @param {Element} node element.
 * @param {Number} opacity alpha level.
 * @private
 */
GFdynamicFeedControl.prototype.setOpacity_ = function(node, opacity) {
  if (node == null) return;
  opacity = Math.max(0, Math.min(1, opacity));
  if (opacity == 0) {
    if (node.style.visibility != 'hidden') {
      node.style.visibility = 'hidden';
    }
  } else {
    if (node.style.visibility != 'visible') {
      node.style.visibility = 'visible';
    }
  }
  if (this.ie) {
    var normalized = Math.round(opacity*100);
    node.style.filter = 'alpha(opacity=' + normalized + ')';
  }
  node.style.opacity = node.opacity = opacity;
};

GFgadget = GFdynamicFeedControl;
