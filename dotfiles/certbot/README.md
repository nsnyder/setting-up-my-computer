# Certbot

All services that need access to certificates should run in the webservices group and user.
This includes Node-red and potentially other services.

`./permissions.sh` should be copied to `/etc/letsencrypt/renewal-hooks/post/permissions.sh`.
It will run after each renewal to ensure that the webservices group/user has the appropriate
permissions to be able to access all certs.

