require! 'components'
require! 'aea/default-helpers'
require! 'aea'
require! './home'

new Ractive do
    el: \body
    template: RACTIVE_PREPARSE('app.pug')
