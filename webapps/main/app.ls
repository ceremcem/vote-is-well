
require! 'components/components'
require! 'aea/defaults'
require! './home'
require! './menu'
require! './login'
require! './about'
require! './tools'
require! './stats'

try
    new Ractive do
        el: \body
        template: RACTIVE_PREPARSE('app.pug')
        data:
            dcs-url: "https://aktos.io/acikteyit"

        oncomplete: ->
            # Let Ractive complete rendering before fetching any other dependencies
            info = PNotify.notice do
                text: "Fetching dependencies..."
                hide: no

            start = Date.now!
            <~ getScriptCached "js/dep.js"
            info.close!
            elapsed = (Date.now! - start) / 1000
            PNotify.info do
                text: "Dependencies are loaded in #{Math.round(elapsed * 10) / 10} s"

            @set "@shared.deps", yes

catch
    loadingError e.stack
