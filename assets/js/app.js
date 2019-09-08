// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

import LiveSocket from "phoenix_live_view"
import "uikit/dist/css/uikit.min.css"
import Icons from "uikit/dist/js/uikit-icons"
import UIkit from "uikit"

UIkit.use(Icons);

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

const Hooks = {
    icon: {
        mounted() {
            UIkit.icon(this.el)
        },
        updated() {
            delete this.el.__uikit__
            UIkit.icon(this.el)
        }
    },
    grid: {
        mounted() {
            UIkit.grid(this.el)
        },
        updated() {
            delete this.el.__uikit__
            UIkit.grid(this.el)
        }
    },
    nav: {
        mounted() {
            UIkit.nav(this.el);
        },
        updated() {
            delete this.el.__uikit__
            UIkit.nav(this.el)
        }
    }
}

let liveSocket = new LiveSocket("/live", { hooks: Hooks })
liveSocket.connect()