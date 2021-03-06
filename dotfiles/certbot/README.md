# Certbot

Use the installation instructions provided by the EFF [here](https://certbot.eff.org/instructions).
I've chosen to install with `snap`.

```
$ sudo apt install snapd
$ snap install certbot --classic
$ sudo certbot certonly --standalone
```

When prompted to setup you the domains, you a certificate should be created for `willowlane.snydern.com`.

All services that need access to certificates should run in the webservices group and user.
This includes Node-red and potentially other services.

`./permissions.sh` should be copied to `/etc/letsencrypt/renewal-hooks/post/permissions.sh`.
It will run after each renewal to ensure that the webservices group/user has the appropriate
permissions to be able to access all certs.

