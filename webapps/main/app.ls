require! 'components'
require! 'aea/default-helpers'
require! 'aea'
require! './home'
require! './menu'
require! './login'
require! './about'
require! './tools'

new Ractive do
    el: \body
    template: RACTIVE_PREPARSE('app.pug')
    data:
        dcs-url: require '../../config' .dcs-url
