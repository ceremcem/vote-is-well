require! 'prelude-ls': {sort-by}

Ractive.components['stats'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    data: ->
        checkFormat: (text) ->
            if text.to-lower-case!.match "sandık"
                return 'green'
            else
                return 'red'

        tweetsGraph: (tweets) ->
            total = 0
            series = []
            for (tweets or []) |> sort-by (.date)
                series.push {key: ..date, value: ++total}

            series
