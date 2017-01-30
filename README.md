# Generate Certification With LetsEncrypt using Docker

## Configuration

You need to set two variables in order to receive the certificate `LETSENCRYPT_EMAIL` and `LETSENCRYPT_HOST`.

Run the service with the following command, replacing the host and email accordingly:

    $ docker-compose run -e LETSENCRYPT_HOST=dev.sangah.com -e LETSENCRYPT_EMAIL=pmis@sangah.com certbot

After the process is terminated you will have a new folder `certs` 
relative to this file where you will find the certificate.