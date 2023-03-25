# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "polyfill", to: "https://polyfill.io/v3/polyfill.min.js?version=3.52.1&features=fetch"
pin "stripe", to: "https://js.stripe.com/v3/"

pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"
pin_all_from "app/javascript/custom", under: "custom"
pin_all_from 'app/javascript/vendor', under: "vendor"
