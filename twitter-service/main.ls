require! 'twitter': Twitter
require! './credentials': {c} # see https://chimpgroup.com/knowledgebase/twitter-api-keys/

client = new Twitter do
  consumer_key: c.consumer_key
  consumer_secret: c.consumer_secret
  access_token_key: c.access_token_key
  access_token_secret: c.access_token_secret

error, tweets <~ client.get 'search/tweets.json', {q: '#ccatesthashtag'}
console.log "Got #{tweets.statuses.length} tweets."
for let orig in tweets.statuses
    console.log "--------------------------------"
    console.log "Orig tweet is: ", orig.text
    error, tweets <~ client.get 'search/tweets.json', {q: "to:#{orig.user.screen_name}", since_id: orig.id}
    for reply in tweets.statuses
        if reply.in_reply_to_status_id is orig.id
            console.log reply.text, "(fav: #{reply.favorite_count})"
        else
            #console.log "Unrelated: ", reply.text
            null
