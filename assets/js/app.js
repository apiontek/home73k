// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// Import icons for sprite-loader
// navbar brand icon
import "../node_modules/@mdi/svg/svg/desktop-classic.svg"; // brand
// other:///
import "../node_modules/@mdi/svg/svg/home.svg";
import "../node_modules/@mdi/svg/svg/account.svg";
import "../node_modules/@mdi/svg/svg/briefcase-account.svg";
import "../node_modules/@mdi/svg/svg/zip-disk.svg";
import "../node_modules/@mdi/svg/svg/typewriter.svg";
import "../node_modules/@mdi/svg/svg/rss.svg";
import "../node_modules/@mdi/svg/svg/account-hard-hat.svg";
// social
import "../node_modules/@mdi/svg/svg/linkedin.svg";
import "../node_modules/@mdi/svg/svg/github.svg";
import "../node_modules/@mdi/svg/svg/key-variant.svg";
import "../raw/gitea.svg";
import "../node_modules/@mdi/svg/svg/goodreads.svg";
import "../node_modules/@mdi/svg/svg/twitter.svg";
import "../node_modules/@mdi/svg/svg/facebook.svg";
import "../node_modules/@mdi/svg/svg/instagram.svg";
import "../node_modules/@mdi/svg/svg/steam.svg";
import "../node_modules/@mdi/svg/svg/discord.svg";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import topbar from "topbar";
import { LiveSocket } from "phoenix_live_view";

// // Bootstrap v5 js imports
// import "bootstrap/js/dist/alert";
import "bootstrap/js/dist/collapse";
// import "bootstrap/js/dist/dropdown";
// Bootstrap helpers
import "./_hamburger-helper";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
