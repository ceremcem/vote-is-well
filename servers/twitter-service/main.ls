require! '../../config': {c, dcs-port}
require! 'dcs': {
    sleep, Actor, DcsTcpClient,
    IoProxyHandler, DriverAbstract, SignalBranch
}
require! './twitter-lib': {TwitterExtended}
require! 'prelude-ls': {unique-by}

client = new TwitterExtended do
    # see https://chimpgroup.com/knowledgebase/twitter-api-keys/
    consumer_key: c.consumer_key
    consumer_secret: c.consumer_secret
    access_token_key: c.access_token_key
    access_token_secret: c.access_token_secret

hashtag = 'TR24Haziran2018'

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


new DcsTcpClient port: dcs-port
    .login do
        user: "twitter-service"
        password: 'YnBXSAD5Xqhbzra3Yw4uR5CxJfY8g8Hj'

class TwitterDriver extends DriverAbstract
    ->
        super!
        @started!

    write: (handle, value, respond) ->
        # we got a write request to the target
        console.log "we got ", value, "to write as ", handle.route
        err = no
        if handle.readonly
            err = yes
            console.log "...not writing because handle is readonly."
        respond err

    read: (handle, respond) ->
        # we are requested to read the handle value from the target
        if handle.name is \ballot-totals
            console.log "getting ballot totals"
            err, res <~ client.get-tweets {q: '#' + hashtag}
            total-ballots = 0
            ballot-tweets = []
            for tweet in res
                #console.log "#{tweet.text}"
                if tweet.retweeted_status
                    # skip retweets
                    continue

                if tweet.extended_entities?.media
                    #console.log "...media is ", that
                    for m in that
                        if m.type is \photo
                            total-ballots++
                            ballot-tweets.push do
                                url: tweet.entities.media.0.url
                                text: tweet.text
                            break
            console.log "#{total-ballots} of #{res.length} tweets contain ballot photos."
            respond err, {count: total-ballots, tweets: ballot-tweets}
        else
            console.log "we are requested to read", handle
            respond err="unknown handle"


# Handle can be in any format that its driver is able to understand.
twitter-driver = new TwitterDriver
handle =
    name: 'ballot-totals'
    readonly: yes
    route: "@twitter-service.total2"
    watch: 1min * 60_000ms

new IoProxyHandler handle, handle.route, twitter-driver

#dump-from-hashtag \TR24Haziran2018
