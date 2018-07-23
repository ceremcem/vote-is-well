
require! 'components'
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
catch
    loadingError e.stack
