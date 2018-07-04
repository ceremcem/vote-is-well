require! 'prelude-ls': {compact}
require! 'actors': {RactiveActor}

Ractive.components['top-menu'] = Ractive.extend do
    template: RACTIVE_PREPARSE('top-menu.pug')

Ractive.components['side-menu'] = Ractive.extend do
    template: RACTIVE_PREPARSE('side-menu.pug')
    isolated: no
    onrender: ->
        $ @find \.ui.sidebar .sidebar!

    computed:
        menu:
            get: ->
                x = []
                    ..push do
                        title: 'Araçlar'
                        url: '#/tools'
                    ..push do
                        title: 'İstatistikler'
                        url: '#/stats'
                    ..push do
                        title: 'Hakkında'
                        url: '#/about'

                #console.log "menu is: ", (x |> compact)
                x |> compact
