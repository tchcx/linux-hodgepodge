## Use TCP/22 as a canary and TCP/$XYZ as the actual SSH port

### SSHD configuration
```
# /etc/ssh/sshd_config.d/51-custom.conf
# Port 22 has no valid authentication mechanisms.
# Port $XYZ has pubkey authN
Port 22
Port $XYZ

Match LocalPort 22
  PermitRootLogin no
  PermitEmptyPasswords no

  PubKeyAuthentication no
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  X11Forwarding no
  AllowTCPForwarding no

Match LocalPort $XYZ
  PermitRootLogin no
  PermitEmptyPasswords no

  PubKeyAuthentication yes
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  X11Forwarding no
  AllowTCPForwarding no
```

### Fail2Ban Jails

```
# /etc/fail2ban/jail.d/sshd.conf - SSH canary on port 22
# One authN round and you're out!
[sshd]
enabled = true
port = 22
ignoreip = $IP

maxretry = 1
findtime = 10m
bantime = 12m

banaction = ufw
banaction_allports = ufw

logpath = /var/log/auth.log
backend = %(sshd_backend)s
```

```
# /etc/fail2ban/jail.d/sshd_main.conf - SSH canary on port $XYZ
# More lenient

[sshd_main]
filter = sshd
enabled = true
port = $XYZ
ignoreip = $IP

maxretry = 3
findtime = 8m
bantime = 6m

banaction = ufw
banaction_allports = ufw

logpath = /var/log/auth.log
backend = %(sshd_backend)s
```

