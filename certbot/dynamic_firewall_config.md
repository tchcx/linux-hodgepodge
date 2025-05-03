## Dynamic Firewall Config
### Open or change firewall rules using CertBot hooks

#### Basic state
```
xyz/tcp                    ALLOW IN    ab.cd.ef.gh/24  # SSH 
443/tcp (Apache Secure)    ALLOW IN    Anywhere        # HTTPS allowed in globally
80/tcp (Apache)            LIMIT IN    Anywhere        # HTTP rate-limited in (redirect to HTTPS)
```

#### PRE hook
```
#! /usr/bin/env bash

## /etc/letsencrypt/renewal-hooks/pre/pre_ufw.sh
## Remember: sudo chmod 750 ../pre_uf.sh

sudo ufw insert 1 allow from 0.0.0.0/0 to any app "CertBot"
```

#### POST hook
```
#! /usr/bin/env bash

## /etc/letsencrypt/renewal-hooks/post/post_ufw.sh
## Remember: sudo chmod 750 ../post_uf.sh

# --force skips interactive y/n for delete
sudo ufw --force delete 1 allow from 0.0.0.0/0 to any app "CertBot" 
```

#### Confirm
```
bla@blah:~ $sudo certbot renew --dry-run
--- SNIP ---
Hook 'pre-hook' ran with output:
 Rule inserted
-- SNIP ---
Hook 'post-hook' ran with output:
 Rule deleted
```

#### UFW state during renewal
```
80/tcp (CertBot)           ALLOW IN    Anywhere        # HTTP non-rate-limited
xyz/tcp                    ALLOW IN    ab.cd.ef.gh/24  # SSH 
443/tcp (Apache Secure)    ALLOW IN    Anywhere        # HTTPS allowed in globally
80/tcp (Apache)            LIMIT IN    Anywhere        # This rule is never reached
```
