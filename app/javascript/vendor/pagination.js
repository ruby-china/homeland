// Keyboard shortcuts for browsing pages of lists
const left_arrow = 37;
const right_arrow = 39;

function prevPage() {
  const link = document.querySelector(".pagination a[rel='prev']");
  if (!link) return;
  var href = link.getAttribute("href");
  if (href && href != document.location && href != "#") {
    Turbo.visit(href);
  }
}

function nextPage() {
  const link = document.querySelector(".pagination a[rel='next']");
  if (!link) return;
  var href = link.getAttribute("href");
  if (href && href != document.location && href != "#") {
    Turbo.visit(href);
  }
}

const paginationHandler = (e) => {
  if (e.target.nodeName == "BODY" || e.target.nodeName == "HTML") {
    if (!e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey) {
      var code = e.which;

      if (code == left_arrow) {
        prevPage();
      } else if (code == right_arrow) {
        nextPage();
      }
    }
  }
};

document.addEventListener("turbo:load", () => {
  document.removeEventListener("keydown", paginationHandler);
  document.addEventListener("keydown", paginationHandler);
});
