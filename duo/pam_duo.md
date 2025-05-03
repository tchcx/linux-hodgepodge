### Duo Push 2FA for SSH and Sudo

#### Install Duo
```
user@host:~$ echo "deb [arch=amd64] https://pkg.duosecurity.com/Ubuntu noble main" | sudo tee -a /etc/apt/sources.list.d/duosecurity.list
user@host:~$ curl -s https://duo.com/DUO-GPG-PUBLIC-KEY.asc | sudo gpg --dearmor -o  /etc/apt/trusted.gpg.d/duo.gpg
user@host:~$ sudo apt update && sudo apt install duo-unix -y
```

#### Configure Duo
```
; user@host:~$ sudo vi /etc/duo/pam_duo.conf

[duo]
; Duo integration key
ikey = $IKEY

; Duo secret key
skey = $SKEY

; Duo API host
host = $HOST.duosecurity.com

; fail open (secure = fail closed)
failmode = safe

; Send command for Duo Push authentication
pushinfo = yes

; Keep autopush off *for now*
autopush = no
```

#### Configure sshd
```
# user@host:~$ sudo vi /etc/ssh/sshd_config.d/51-custom.conf

# Fail2Ban canary
Match LocalPort 22
  PermitRootLogin no
  PermitEmptyPasswords no

  PubKeyAuthentication no
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  X11Forwarding no
  AllowTCPForwarding no

# Main SSH port
Match LocalPort $PORT
  PermitRootLogin no
  PermitEmptyPasswords no

  PasswordAuthentication no
  PubKeyAuthentication yes
  ChallengeResponseAuthentication yes
  AuthenticationMethods publickey,keyboard-interactive
  X11Forwarding no
  AllowTCPForwarding no
```

#### Configure PAM (sshd and sudo)
```
# user@host:~$ sudo vi /etc/pam.d/common-auth

# Comment this out
#auth   [success=1 default=ignore]      pam_unix.so nullok

# Duo - Add these
auth    requisite pam_unix.so nullok_secure
auth    [success=1 default=ignore] /lib64/security/pam_duo.so
```

#### Confirm functionality
```
# Test SSH (enroll if needed)
user@laptop: ~$ ssh -i $somekey -p $someport user@host

# Test sudo
user@laptop: ~$ sudo ls
```

### Update Duo Config
```
; push automatically
autopush = yes
```
