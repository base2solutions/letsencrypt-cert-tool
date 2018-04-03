Letsencrypt Cert Tool
===============

This tool creates [Let's Encrypt](https://letsencrypt.org/) certificates using [AWS Route53](https://aws.amazon.com/route53). It uses [Certbot](https://certbot.eff.org) to automate certificate requests, and the [AWS CLI](https://aws.amazon.com/cli/) to automate DNS challenge record creation and cleanup. 

Usage
----------------------
### Building the Docker Image
***Note: This process is automated and you can optionally use the public image hosted on the docker registry at <> if you don't want to build it yourself.***
1. Build and tag an image by using the Dockerfile in this directory.
```
docker build --rm -t <image_name> .
```
2. Optionally, push the image to the registry.
```
docker push <image_name>
```

### Running the Docker Container

#### Prerequisites
 * You must have an IAM user AWS_ACCESS_KEY_ID and an AWS_SECRET_ACCESS_KEY with permissions to [create and modify records sets in Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/access-control-managing-permissions.html).
 * You must have an entry provisioned in a *Public* Route53 Zone for the domain that you would like to generate a certificate for.

#### Usage
1. Create a volume to store your cert data in if you have not already done so.
```
docker volume create autocerts
```

2. Run the container, making sure to set the environment variables appropriately.
```
docker run --rm -it -e "AWS_ACCESS_KEY_ID=<Access Key ID>" -e "AWS_SECRET_ACCESS_KEY=<Secret Access Key>" -e "CERTBOT_EMAIL=<Registration Email>" -v <volume name>:/autocerts base2Solutions/letsencrypt-cert-tool --domains <domain>
```
Upon completion, you should see a log message similar to the following.
```
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /autocerts/letsencrypt/live/testdomain.base2d.com/fullchain.pem.
   Your cert will expire on 2018-07-02. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /autocerts/letsencrypt. You should make
   a secure backup of this folder now. This configuration directory
   will also contain certificates and private keys obtained by Certbot
   so making regular backups of this folder is ideal.
```

3. To view your certificates and key, simply mount the volume in a container and browse to the directory mentioned above. You can also mount this directory directly in to another container (such as nginx) and make use of the certificate.
```
docker run --rm -it -v autocerts:/autocerts busybox sh
```

