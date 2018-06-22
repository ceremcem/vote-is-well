require! 'twitter': Twitter
require! 'credentials': {c}

client = new Twitter do
  consumer_key: c.consumer_key
  consumer_secret: c.consumer_secret
  access_token_key: c.access_token_key
  access_token_secret: c.access_token_secret

error, tweets <~ client.get 'search/tweets.json', {q: '#ccatesthashtag'}
console.log "Got #{tweets.statuses.length} tweets."
for let tweets.statuses
    console.log "--------------------------------"
    console.log "Orig tweet is: ", ..text
    error, tweets <~ client.get 'search/tweets.json', {q: "to:#{..user.screen_name}", since_id: ..id}
    for reply in tweets.statuses
        console.log reply.text, "(fav: #{reply.favorite_count})"
