const hoverTime = 50
const fetchers = {}
const doc = document.implementation.createHTMLDocument('prefetch')
const xhr = new XMLHttpRequest()

function fetchPage(url, success) {
  xhr.open('GET', url)
  xhr.setRequestHeader('VND.PREFETCH', 'true')
  xhr.setRequestHeader('Accept', 'text/html')
  xhr.onreadystatechange = () => {
    if (xhr.readyState !== XMLHttpRequest.DONE) return
    if (xhr.status !== 200) return
    success(xhr.responseText)
  }
  xhr.send()
}

function prefetchTurbolink(url) {
  fetchPage(url, responseText => {
    doc.open()
    doc.write(responseText)
    doc.close()
    const snapshot = Turbolinks.Snapshot.fromHTMLElement(doc.documentElement)
    Turbolinks.controller.cache.put(url, snapshot)
  })
}

function prefetch(url) {
  if (prefetched(url)) return
  prefetchTurbolink(url)
}

function prefetched(url) {
  return location.href === url || Turbolinks.controller.cache.has(url)
}

function prefetching(url) {
  return !!fetchers[url]
}

function cleanup(event, href) {
  const element = event.target
  clearTimeout(fetchers[href])
  fetchers[href] = null
  element.removeEventListener('mouseleave', mouseleave)
}

function mouseleave(event, href) {
  xhr.abort()
  cleanup(event, href)
}

document.addEventListener('mouseover', event => {
  const { target } = event;
  if (target.hasAttribute('data-remote')) return
  if (target.getAttribute('data-prefetch') === 'false') return
  if (target.getAttribute('target') === '_blank') return
  const href = target.getAttribute("href") || target.getAttribute("data-prefetch");

  // skip no fetch link
  if (!href) return
  // skip anchor
  if (href.startsWith('#')) return
  // skip outside link
  if (href.includes("://") && !href.startsWith(window.location.origin)) return

  if (prefetched(href)) return
  if (prefetching(href)) return
  cleanup(event, href)
  event.target.addEventListener('mouseleave', (event) => mouseleave(event, href))
  fetchers[href] = setTimeout(() => prefetch(href), hoverTime)
})
