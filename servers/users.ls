require! 'dcs': {Actor, DcsTcpClient, CouchDcsClient, sleep}
require! 'colors': {bg-yellow}
require! '../config': {dcs-port, default-passwd}
require! 'dcs/src/auth-helpers': {hash-passwd}

hardcoded-users =
    'guest':
        passwd-hash: hash-passwd "guest"

new DcsTcpClient port: dcs-port
    .login do
        user: "auth-db"
        password: default-passwd

new class Users extends Actor
    ->
        super "Users"
        @subscribe '@auth-db'
        db = new CouchDcsClient route: \@db-proxy

        process-users = ~>
            <~ :lo(op) ~>
                @log.log "Getting users..."
                err, res <~ db.view 'clients/getUsers'
                if err
                    @log.err "Can not get users, err is: ", err
                    @log.log "Retrying in 5 seconds"
                    <~ sleep 5000ms
                    lo(op)
                else
                    @log.log "Number of users from database: ", res.length
                    users = {}
                    for res
                        users[..value.id] = ..value

                    users <<< hardcoded-users

                    @log.log "Sending users..."
                    err, msg <~ @send-request {to: '@auth-db', -debug}, users
                    if err
                        @log.err "Failed to send users: ", err
                    else
                        @log.success "Users sent:", msg.data

        @on-every-login ~>
            process-users!
        db.on-topic '@db-proxy.change.view.clients/getUsers', (msg) ~>
            process-users!
        db.on-topic '@db-proxy.change.view.clients/getClients', (msg) ~>
            db.log.debug "Received client change but it's not a user. Doing nothing."
