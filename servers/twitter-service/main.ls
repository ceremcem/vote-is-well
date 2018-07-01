require! 'twitter': Twitter
require! '../../config': {c} # see https://chimpgroup.com/knowledgebase/twitter-api-keys/
require! 'dcs': {SignalBranch}

client = new Twitter do
  consumer_key: c.consumer_key
  consumer_secret: c.consumer_secret
  access_token_key: c.access_token_key
  access_token_secret: c.access_token_secret


get-replies = (tweet, callback) ->
    '''
    Pushes hierarchical replies into `tweet.replies` attribute
    '''
    user = tweet.user.screen_name
    tweet-id = tweet.id
    _replies = []
    error, tweets <~ client.get 'search/tweets.json', {q: "to:#{user}", since_id: tweet-id}
    branch = new SignalBranch
    for let reply in tweets.statuses
        #console.log "examining reply: #{reply.id}"
        if reply.in_reply_to_status_id is tweet-id
            signal = branch.add!
            #console.log "got a reply: #{reply.in_reply_to_status_id} <<< #{reply.id}: #{reply.text}"
            err, tweets <~ get-replies reply
            reply.replies = tweets
            _replies.push reply
            signal.go!
        else
            #console.log "Unrelated: ", reply.text
            null
    err, res <~ branch.joined
    #console.log "Returning replies for #{user}: ", _replies
    callback err, _replies

dump-tweet = (tweet, level=0) ->
    console.log "#{'-' * level}#{if level > 0 then '>' else ''} #{tweet.text} (<3 = #{tweet.favorite_count})"
    for tweet.replies or []
        dump-tweet .., (level+1)

dump-from-hashtag = (hashtag) ->
    error, tweets <~ client.get 'search/tweets.json', {q: '#' + hashtag}
    console.log "Got #{tweets.statuses.length} tweets."
    for let orig in tweets.statuses
        err, tweets <~ get-replies orig
        console.log "--------------------------------"
        console.log "Orig tweet is: "
        dump-tweet orig
        console.log "...and its replies: "
        for tweets
            dump-tweet .., 1
        console.log "================================"

#dump-from-hashtag \ccatesthashtag
error, tweets <~ client.get 'favorites/list.json'
console.log tweets
