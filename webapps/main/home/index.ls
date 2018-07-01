nested-cities = require 'db/turkey-cities-json/nested'

Ractive.components['home'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        @set \cities, nested-cities

        @on do
            selectCity: (ctx, item, proceed) ->
                @set \districts, [{id: .., name: ..} for item.districts]
                proceed!

            createTweet: (ctx) ->
                record = @get \record
                
                @set \tweetText, """
                \#TR24Haziran2018 #{record.city}/#{record.district}/#{record.ballot}
                """
