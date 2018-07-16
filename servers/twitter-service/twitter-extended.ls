require! 'dcs': {SignalBranch, Logger}
require! 'twitter': Twitter
require! 'moment'


export get-unix-ts = (tweet) ->
    # returns unix timestamp in seconds
    moment tweet.created_at, 'dd MMM DD HH:mm:ss ZZ YYYY', 'en' .value-of!

flatten-tweets = (tweets, level=1) ->
    _flatten = []
    for let tweets
        ..level = level
        _flatten.push ..
        _flatten ++= flatten-tweets ..replies, (level + 1)
        delete ..replies
    return _flatten

export class TwitterExtended extends Twitter
    (credentials) ->
        super credentials
        @log = new Logger "twitter client"
        @endpoint = credentials.endpoint
        @environment = credentials.environment

    get-replies: (tweet, opts, callback) ->
        '''
        Pushes tweet replies into `tweet.replies` attributes recursively

        opts: (optional)
            recursive: true/false
        '''

        # normalize parameters
        if typeof! opts is \Function
            callback = opts
            opts = {}

        user = tweet.user.screen_name
        tweet-id = tweet.id
        _replies = []
        _error = null
        #console.log "getting replies for #{user} from #{tweet-id}"
        error, tweets <~ @get-all {q: "to:#{user}", since_id: tweet-id}
        branch = new SignalBranch
        if error
            _error := error
        else
            for let reply in tweets
                #console.log "examining reply: #{reply.id}, reply to: ", reply.in_reply_to_status_id
                if reply.in_reply_to_status_id is tweet-id
                    #console.log "got a reply: #{reply.in_reply_to_status_id} <<< #{reply.id}: #{reply.text}"
                    if opts.recursive
                        signal = branch.add!
                        err, tweets <~ @get-replies reply, opts
                        # TODO: handle  [ { message: 'Rate limit exceeded', code: 88 } ] errors
                        unless err
                            reply.replies = tweets
                        _replies.push reply
                        signal.go!
                    else
                        reply.replies = []
                        _replies.push reply
                else
                    #console.log "Unrelated: ", reply.text
                    null
        err, res <~ branch.joined
        #console.log "Returning replies for #{user}: ", _replies
        callback _error, _replies


    get-flat-replies: (tweet, opts, callback) ->
        '''
        Adds `level` attribute to each reply
        '''
        # normalize parameters
        if typeof! opts is \Function
            callback = opts
            opts = {}

        err, replies <~ @get-replies tweet, opts

        #console.log "got flat replies: ", JSON.stringify [..text for replies]
        res2 = null
        unless err
            res2 = flatten-tweets replies
        callback err, res2


    get-all: (query, callback) ->
        since_id = query.since_id or 0
        max_id = 0
        total = 0
        page-count = 100 # This is maximum value
        _err = null
        _res = []

        if @environment
            next = null
            <~ :lo(op) ~>
                url = "tweets/search/#{@endpoint}/#{@environment}.json"
                opts =
                    query: query.q
                if next
                    opts.next = that
                err, res <~ @get (query.url or url), opts
                if err
                    console.log "error is: ", err 
                    _err := err
                    return op!
                _res ++= res.results
                if res.next
                    next := that
                    lo(op)
                else
                    return op!

            callback _err, _res
        else
            <~ :lo(op) ~>
                url = "search/tweets.json"
                opts =
                    q: query.q
                    since_id,
                    max_id
                    count: page-count

                err, tweets <~ @get (query.url or url), opts
                if err
                    console.error "------------------------------"
                    console.error "we have an error here: ", err
                    console.error "------------------------------"
                    _err := err
                    return op!
                _res ++= tweets.statuses
                count = tweets.statuses?.length or 0
                total += count
                #console.log "...since #{since_id} got #{count} tweets. (total: #{total})"
                if tweets.statuses.length < page-count
                    #console.log "__this seems the last page."
                    return op!
                # get until the bottom of current tweets
                for tweets.statuses or []
                    if ..id < max_id or max_id is 0
                        max_id := ..id
                lo(op)
            if _err
                _res := null
            callback _err, _res

    send-tweet: (tweet, callback) ->
        '''
        tweet: {text, reply-to}

            text        : content of tweet
            reply-to    : the tweet object to reply to
        '''
        tw = {status: tweet.text}
        if tweet.reply-to
            id = that.id_str
            username = that.user?.screen_name
            throw "id and username is required." unless id or username
            tw <<< do
                status: "@#{username} #{tw.status}"
                in_reply_to_status_id: "#{id}"
        @post 'statuses/update', tw, callback
