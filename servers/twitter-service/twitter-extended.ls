require! 'dcs': {SignalBranch, Logger}
require! 'twitter': Twitter

export class TwitterExtended extends Twitter
    (credentials) ->
        super credentials
        @log = new Logger "twitter client"

    get-replies: (tweet, callback) ->
        '''
        Pushes hierarchical replies into `tweet.replies` attribute
        '''
        user = tweet.user.screen_name
        tweet-id = tweet.id
        _replies = []
        error, tweets <~ @get 'search/tweets.json', {q: "to:#{user}", since_id: tweet-id}
        branch = new SignalBranch
        for let reply in tweets.statuses
            #console.log "examining reply: #{reply.id}"
            if reply.in_reply_to_status_id is tweet-id
                signal = branch.add!
                #console.log "got a reply: #{reply.in_reply_to_status_id} <<< #{reply.id}: #{reply.text}"
                err, tweets <~ @get-replies reply
                reply.replies = tweets
                _replies.push reply
                signal.go!
            else
                #console.log "Unrelated: ", reply.text
                null
        err, res <~ branch.joined
        #console.log "Returning replies for #{user}: ", _replies
        callback err, _replies


    flatten-replies: (tweet) ->
        _flatten = []
        for tweet.statuses
            _flatten.push ..
        return _flatten

    get-all: (query, callback) ->
        since_id = 0
        max_id = 0
        total = 0
        page-count = 100
        _err = null
        _res = []
        <~ :lo(op) ~>
            err, tweets <~ @get 'search/tweets.json', {
                q: query.q
                since_id,
                max_id
                count: page-count
            }
            if err
                console.error "we have an error here: ", err
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
        callback _err, _res
