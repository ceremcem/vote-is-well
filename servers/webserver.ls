require! <[ fs path express ]>
require! '../config': {dcs-port, webserver-port}
require! 'dcs': {DcsTcpServer, AuthDB, Actor}
require! 'dcs/browser': {DcsSocketIOServer}

# -----------------------------------------------------------------------------
# Webserver
# -----------------------------------------------------------------------------
pub-dir = development-public = "#{__dirname}/../scada.js/build/"
app = express!
http = require \http .Server app

# for debugging purposes, print out what is requested
app.use (req, res, next) ->
        filename = path.basename req.url
        extension = path.extname filename
        #console.log "File: #{filename} was requested."
        next!

console.log "serving static folder: /"
app.use "/", express.static path.resolve "#{pub-dir}/main"

http.listen webserver-port, ->
    console.log "listening on *:#{webserver-port}"

process.on 'SIGINT', ->
    console.log 'Received SIGINT, cleaning up...'
    process.exit 0


# -----------------------------------------------------------------------------
# DCS section
# -----------------------------------------------------------------------------
db = new AuthDB (require './users' .hardcoded)

new class Users extends Actor
    action: ->
        @on-topic \@auth-db, (msg) ~>
            db.update msg.data
            @send-response msg, {+ok}

# create socket.io server
new DcsSocketIOServer http, do
    db: db

# start a TCP Proxy to share messages over dcs network
new DcsTcpServer do
    db: db
    port: dcs-port
