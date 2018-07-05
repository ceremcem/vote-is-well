require! '../../config': {c, dcs-port}
require! './twitter-extended': {TwitterExtended, get-unix-ts}
require! 'dcs': {
    DcsTcpClient, IoProxyHandler, DriverAbstract, SignalBranch
}
require! 'prelude-ls':  {sort-by, filter, map, find, compact}
require! './asciifold': {asciifold}

hashtag = 'TR24Haziran2018'

client = new TwitterExtended do
    # see https://chimpgroup.com/knowledgebase/twitter-api-keys/
    consumer_key: c.consumer_key
    consumer_secret: c.consumer_secret
    access_token_key: c.access_token_key
    access_token_secret: c.access_token_secret

/*
err, res <~ client.get 'statuses/user_timeline.json', {screen_name: "acikteyit_w1"}
for let index, tweet of res
    console.log "sending reply to #{tweet.user.screen_name} (#{tweet.id}): #{tweet.text}"
    err, res <~ client.send-tweet {text: "reply seq #{index}", reply-to: tweet}
    unless err
        console.log "reply is sent: ", res
    else
        console.log "reply failed!"
return
*/

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
            client.log.log "getting ballot totals"
            err, res <~ client.get-all {q: '#' + hashtag}
            total-ballots = 0
            ballot-tweets = []
            if err
                console.log "we couldn't get the hashtag results"
                return respond err 
            else
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
                                    tweet: tweet
                                    url: tweet.entities.media.0.url
                                    text: tweet.text
                                    date: get-unix-ts tweet
                                break

            ballot-tweets = sort-by (.date), ballot-tweets # must be in order for graph
            last-tweet = ballot-tweets.5
            client.log.log "#{total-ballots} of #{res.length} tweets contain photos."

            client.log.log "Getting replies..."
            branch = new SignalBranch
            for let ballot-tweets
                signal = branch.add!
                err, res <~ client.get-flat-replies ..tweet
                unless err
                    ..replies = res
                signal.go!
            err, res <~ branch.joined
            for let ballot-tweets
                console.log "(#{..tweet.id})", ..text
                unless ..replies
                    console.log "_____ no replies can be fetched?"
                else
                    for ..replies
                        console.log (">" * ..level), ..text

                # check if tweet text is okay
                if asciifold ..text .match /sandik: [a-z]+\/[a-z]+\/[0-9]+/
                    #console.log "Tweet seems okay."
                    ..ok = yes
                else
                    console.error "Tweet seems not okay! checking if marked before..."
                    unless typeof! ..replies is \Array
                        # if we fetched the replies succesfully, they must be an array.
                        console.log "...didn't we fetch the replies correctly?"
                    else
                        service-replies = ..replies
                            |> filter (.user.screen_name is c.screen_name)
                            |> map ((t)-> {
                                cmd: (t.text.match /\(Servis: ([^\)]*)\).*/ ?.1),
                                date: t.created_at
                                })
                            |> compact

                        console.log "Current service replies are: ", JSON.stringify service-replies
                        if find (.cmd is "NOK"), service-replies
                            console.log "...marked before, not marking again."
                        else
                            console.log "...not marked before, marking"
                            /*
                            err, res <~ client.send-tweet do
                                text: "(Servis: NOK) Tweet formatı uygun değil. (bkz. https://ceremcem.github.io/acikteyit/\#/tools)",
                                reply-to: ..tweet
                            unless err
                                console.log "Response to my tweet is sent."
                            else
                                console.error "Can not respond to the tweet!"
                            */

                # cleanup tweet from response
                delete ..tweet
                if ..replies
                    ..replies = [..text for that]

            #console.log JSON.stringify ballot-tweets.0
            respond err, {count: total-ballots, tweets: ballot-tweets}
        else
            console.log "we are requested to read", handle
            respond err="unknown handle"


# Handle can be in any format that its driver is able to understand.
handles =
    * name: 'ballot-totals'
      readonly: yes
      route: "@twitter-service.total2"
      watch: 10min * 60_000ms
    ...

twitter-driver = new TwitterDriver

# Fire up handles
for let handles
    new IoProxyHandler .., ..route, twitter-driver
