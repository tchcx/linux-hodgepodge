### Apache2 Jails for AuthZ and Bots

#### Apache2 Config to Restrict IPs to /admin/
```
# /etc/apache2/sites-enabled/site.conf
   <Location /admin>
     Require ip $ADDRESS_A
     Require ip $ADDRESS_B
     Require ip $ADDRESS_C
     Require ip 127.0.0.1
   </Location>
```

#### Fail2Ban Config to Monitor Apache2 Logs
```
# /etc/fail2ban/jail.d/apache.log
# We're erring on the side of caution
# Only block pretty aggressive traffic

[apache-auth]
enabled  = true
port     = 80,443
filter   = apache-auth
logpath  = /var/log/apache2/error.log
maxretry = 3
bantime = 30
findtime = 45

[apache-badbots]
enabled  = true
port     = 80,443
filter   = apache-badbots
logpath  = /var/log/apache2/error.log
maxretry = 3
bantime = 30
findtime = 45
```
