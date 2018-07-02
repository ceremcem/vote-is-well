nested-cities = require 'db/turkey-cities-json/nested'
require! 'aea': {copy-to-clipboard}
require! 'actors': {RactiveActor}

Ractive.components['tools'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        @set \cities, nested-cities

        actor = new RactiveActor this
            ..on-topic "@twitter-service.total", (msg) ~>
                debugger

            ..on-every-login ~>
                err, res <~ actor.send-request {to: '@twitter-service.update'}, null
                console.log "response from twitter service:", res.data
                @set \twitter.total, res.data

        @on do
            selectCity: (ctx, item, proceed) ->
                @set \districts, [{id: .., name: ..} for item.districts]
                proceed!

            createTweet: (ctx) ->
                btn = ctx.component
                record = @get \record
                unless record.city
                    return btn.error "Şehir boş geçilemez."
                unless record.district
                    return btn.error "İlçe boş geçilemez."
                unless record.ballot
                    return btn.error "Sandık numarası boş geçilemez."

                @set \tweetText, """
                \#TR24Haziran2018 Sandık: #{record.city}/#{record.district}/#{record.ballot}
                """
                @set \mymodal1, true

            copyTweet: (ctx) ->
                copy-to-clipboard @get \tweetText
                PNotify.info do
                    title: "Kopyalandı"
                    text: """
                        Tweet panoya kopyalandı.
                        """
