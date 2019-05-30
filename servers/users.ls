require! '../config': {dcs-port, default-passwd}
require! 'dcs/src/auth-helpers': {hash-passwd}

export hardcoded =
    'public':
        passwd-hash: hash-passwd "public"
        routes:
            \@twitter-service.total2.**

    'twitter-service':
        passwd-hash: hash-passwd "YnBXSAD5Xqhbzra3Yw4uR5CxJfY8g8Hj"

    # accounts for initialization services
    'auth-db':
        passwd-hash: hash-passwd default-passwd
        routes: \@db-proxy.**

if require.main is module
    require! 'dcs': {Actor, DcsTcpClient, sleep}
    require! 'colors': {bg-yellow}
    require! 'dcs/services/couch-dcs/client': {CouchDcsClient}


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
                users = hardcoded

                @log.log "Sending users..."
                err, msg <~ @send-request {to: '@auth-db'}, users
                if err
                    @log.err "Failed to send users: ", err
                else
                    @log.success "Users sent:", msg.data

            @on-every-login ~>
                process-users!
