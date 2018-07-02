Ractive.components['login'] = Ractive.extend do
    template: RACTIVE_PREPARSE('login.pug')
    isolated: no
    data: ->
        user: null
        password: null

    onrender: ->
        username-input = $ @find \input.username
        password-input = $ @find \input.password
        username-input.focus!

        username-input.on \keyup, (key) ~>
            inp = username-input.val!
            if inp.length < 2
                lower = inp.to-lower-case!
                #@set \warnCapslock, (inp isnt lower)
                username-input.val lower

        @on do
            clickLogin: (ctx) ->
                @find-wid \login-button .fire \click

            focusPassword: (ctx) ->
                password-input.focus!

            success: (ctx) ->
                @find-all-components! .for-each (x) ~>
                    if (x.get \wid) is \go-to-opening-scene => x.fire \click
