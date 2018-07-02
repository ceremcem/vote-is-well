require! 'dcs': {Actor, DcsTcpClient, CouchDcsClient, sleep}
require! 'colors': {bg-yellow}
require! '../config': {dcs-port, default-passwd}
require! 'dcs/src/auth-helpers': {hash-passwd}

hardcoded-users =
    'public':
        passwd-hash: hash-passwd "public"

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
            users = hardcoded-users

            @log.log "Sending users..."
            err, msg <~ @send-request {to: '@auth-db'}, users
            if err
                @log.err "Failed to send users: ", err
            else
                @log.success "Users sent:", msg.data

        @on-every-login ~>
            process-users!
