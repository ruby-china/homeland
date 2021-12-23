import * as bootstrap from "bootstrap/dist/js/bootstrap.esm";
window.bootstrap = bootstrap;
require("bootstrap-select");

document.addEventListener("turbolinks:load", () => {
  $("select.bootstrap-select").selectpicker({
    size: 10,
    style: "btn-secondary",
  });
});
document.addEventListener("turbolinks:before-cache", () => {
  $("select.bootstrap-select")
    .selectpicker("destroy")
    .addClass("bootstrap-select");
});
