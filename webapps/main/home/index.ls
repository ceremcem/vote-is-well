nested-cities = require 'db/turkey-cities-json/nested'
require! 'aea': {copy-to-clipboard}

Ractive.components['home'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        @set \cities, nested-cities

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
