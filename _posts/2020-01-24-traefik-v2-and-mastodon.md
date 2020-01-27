---
title: Traefik v2 and Mastodon, a wonderful couple!  
subtitle: A practical guide to setting up Mastodon behind Traefik v2 using docker-compose  
layout: post
author: nico
category: article
published: true
---

I've been using [Mastodon](https://joinmastodon.org) for quite a while now. And I really like the idea behind it, especially from a _distributed web_ perspective. Taking _decentralization_ a step further, my next step was to set up an own instance of Mastodon.

In this blog post I'd like to take you on the journey of setting up an own instance of Mastodon using [Docker(-Compose)](https://www.docker.com) and [Traefik v2.1](https://traefik.io).

Why do I think we need yet another tutorial for this? Well, at first there seem to be not so many tutorials for Traefik v2 around yet. Searching the internet mostly yields Traefik v1 related guides and tutorials. Secondly, there are two things I just couldn't achieve using the once existing Mastodon docker guide (by the time of writing this guide, Mastodon removed its docker guide completely):

* I wanted to have all required components managed within the docker-compose file
* I wanted to have as few manual configuration as possible

Despite of having a good documentation, there is a design decision I dislike in the Mastodon docker guide. That is they place the nginx reverse-proxy outside of docker hence requiring the administrator to manually setup and configure a separate nginx on her box.

So, this guide goes another way :)

### The new docker guide

This guide shows how you can setup your own instance of Mastodon using a single docker-compose file.

In the former Mastodon docker guide and the `docker-compose.yml` from Mastodons [repository](https://github.com/tootsuite/mastodon) they place the nginx reverse-proxy outside of docker hence requiring the administrator to manually setup and configure a separate nginx on her box.

I really like keeping things as simple as possible so I tried reducing the complexity by integrating Traefik as reverse-proxy and its configuration into the docker-compose file ending up with a single file that could fire up the complete Mastodon instance :)

Additional features (over the original docker-compose from the repo):

* [Traefik v2](traefik.io) as reverse-proxy doing:
    * HTTPS redirection
    * TLS termination
    * automagic certificate handling with [Let's Encrypt](https://letsencrypt.org)
    * path based traffic routing to `web` and `streaming` containers of Mastodon

#### Prerequisites

Before we start there are some things that we need to prepare:

* We need a `<DOMAIN>` pointing to your box (like `social.yourdomain.com`)

```
social.yourdomain.com    A    ip.of.your.box
```

* Your box needs to be reachable from the internet on ports `80` and `443`
* We need to have Docker and `docker-compose` installed on our box
    * Install guide for [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
    * Install guide for [docker-compose](https://docs.docker.com/compose/install/)

Before you continue, make sure these things are done.

#### For the impatient

If you just want to get things running, follow these steps:

* Download my [docker-compose.yml](https://gist.github.com/smashnet/38cf7c30cb06427bab78ae5ab0fd2ae3) **and fill in the variables to your needs**
* In the same directory run:
    * `touch .env.production`
    * On linux machines: `sudo chown 991:991 .env.production`
    * `docker-compose run --rm -v $(pwd)/.env.production:/opt/mastodon/.env.production web bundle exec rake mastodon:setup`
        * This will guide you through some steps setting up things like `Users`, `Secrets`, etc. don't worry.
    * `docker-compose up -d`

That should be it. You now have an instance of Mastodon running behind a traefik reverse-proxy handling HTTPS redirection, TLS termination and automagic setup and renewal of Let's Encrypt certificates. Persistence data from the containers is stored in folders located in the same directory as your `docker-compose.yml`.

#### For the curious

Well, there are a lot of things going on in the `docker-compose.yml` that you might want to understand. Basically, it's the whole setup of `traefik` and the corresponding Mastodon related configuration.

So let's go through the services being started in the docker-compose file and see what happens.

#### Traefik

At first, we start `traefik` so we have someone answering requests from outside. More specifically, traefik's job will be to route requests headed to your `<DOMAIN>` further to your Mastodon instance and back outside. While doing this, traefik handles:

* HTTPS redirection
* TLS termination
* automagic certificate handling with Let's Encrypt
* path based traffic routing to `web` and `streaming` containers of Mastodon

Let's have a look at the `traefik` part of the `docker-compose.yml`:

```
  traefik:
    image: traefik:2.1
    container_name: "traefik"
    restart: always
    command:
#      - "--log.level=DEBUG"
      - "--api.dashboard=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencrypt.acme.email=<LETSENCRYPT_MAIL_ADDRESS>"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    labels:
      - "traefik.enable=true"
      # Dashboard
      - "traefik.http.routers.traefik.rule`(Host(`<DOMAIN>`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`)))"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.middlewares=dashboardauth"
      - "traefik.http.middlewares.dashboardauth.basicauth.users=admin:<TRAEFIK_DASHBOARD_ADMIN_PASSWORD>"
      # HTTPS Redirect
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=web"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https@docker"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt
    networks:
      - external_network
```

At first glance, we see there is a lot of configuration covered by `commands` and `labels`. This is intended, as our goal is to have a `docker-compose.yml` that is as self-contained as possible. To understand why certain things are `commands` and others are `labels` we must know that Traefiks configuration is composed of a `static` part and a `dynamic` part. For further details, there are some great explanations in the [Traefik documentation](https://docs.traefik.io/getting-started/configuration-overview/).

###### Static configuration

The `static` configuration deals with settings that are required at startup time. In this case that are all settings set as `commands` in our `docker-compose.yml`:

`--api.dashboard=true`
* We want Traefik to show its [dashboard](https://docs.traefik.io/operations/dashboard/)

`--entrypoints.web.address=:80`
* We want Traefik to listen for HTTP requests on port `80`

`--entrypoints.websecure.address=:443`
* We want Traefik to listen for HTTPS requests on port `443`

`--providers.docker=true`
* `providers` are sources of dynamic configuration. So this command tells Treafik to accept dynamic configuration found in docker labels

`--providers.docker.exposedbydefault=false`
* By default, Traefik assumes that every running docker container wants to be reachable. As our scenario has some services that don't require outside accessibility we set this setting to `false`.
* We lateron explicitly set the label `traefik.enable=true` for every service that should be routed through Traefik.

`--certificatesresolvers.letsencrypt.acme.httpchallenge=true`
* We create the certificate resolver `letsencrypt`
* The Let's Encrypt certificate resolver should use a [HTTP challenge](https://docs.traefik.io/https/acme/#httpchallenge) to verify our server. That's also the reason why traefik must also have an entrypoint on port `80`.

`--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web`
* The entrypoint for port `80` is called `web` (`--entrypoints.WEB.address=:80`, remember?) so we have to set it here for the HTTP challenge

`--certificatesresolvers.letsencrypt.acme.email=<LETSENCRYPT_MAIL_ADDRESS>`
* Just type in some mail address where Let's Encrypt can reach you in case your certificate is about to expire and auto renewal failed

`--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json`
* Path and JSON file where Keys and certificates are stored. This path must be a `bind` or `volume` otherwise your certificate and keys will be lost on each container restart.

That's it for the static configuration. We have successfully set up the Traefik dashboard, endpoints for HTTP and HTTPS, docker as provider for dynamic configuration, and a certificate resolver handling Let's Encrypt stuff.

###### Dynamic configuration

Let's move on to the `dynamic` configuration found in the `labels` section. These configuration items are related to "How do I access Traefiks dashboard?" and "HTTPS redirection".

We start with the relevant labels for accessing the Traefik dashboard:

`traefik.enable=true`
* We want the Traefik dashboard to be accessible through Traefik

`traefik.http.routers.traefik.rule=(Host(``<DOMAIN>``) && (PathPrefix(``/api``) || PathPrefix(``/dashboard``)))`
* This creates a new router `traefik` handling all requests to `<DOMAIN>` with paths `/api` and `/dashboard` (and sub paths).

`traefik.http.routers.traefik.service=api@internal`
* The service our router `traefik` should forward to is `api@internal`. That's the internal service providing the dashboard.

`traefik.http.routers.traefik.tls.certresolver=letsencrypt`
* We want to access our dashboard securely. So should there be no certificate for `<DOMAIN>`, use the certificate resolver `letsencrypt` (which we created in our static configuration) to get one

`traefik.http.routers.traefik.entrypoints=websecure`
* The router `traefik` should listen on our endpoint `websecure` (which basically means port 443)

`traefik.http.routers.traefik.middlewares=dashboardauth`
* Add the middleware `dashboardauth` to our router `traefik`
* Middlewares are there to do something with a request before it is routed to the service. In this case a Basic Auth. More on this in the next line.

`traefik.http.middlewares.dashboardauth.basicauth.users=admin:<TRAEFIK_DASHBOARD_ADMIN_PASSWORD>`
* The middleware `dashboardauth` is created and should do `basicauth` with the following `users`
* admin:<TRAEFIK_DASHBOARD_ADMIN_PASSWORD>
* IMPORTANT: <TRAEFIK_DASHBOARD_ADMIN_PASSWORD> is an MD5 hash of the password as used in htpasswd files
* Use e.g. [http://www.htaccesstools.com/htpasswd-generator/](http://www.htaccesstools.com/htpasswd-generator/) to bring your password in the correct form

That's all we need to have our Traefik dashboard being accessible via HTTPS.

The next labels make Traefik redirect HTTP requests on port 80 to HTTPS.

`traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)`
* This creates a new router `http-catchall` and defines a rule that all requests should be handled by this router

`traefik.http.routers.http-catchall.entrypoints=web`
* The router `http-catchall` should handle requests coming from the entrypoint `web` (Port 80)

`traefik.http.routers.http-catchall.middlewares=redirect-to-https@docker`
* This router does not route to a service but we use a middleware that does the HTTPS redirection for us. We call the middleware `redirect-to-https` and define it in the next line. The `@docker` is optional and tells Traefik that the middleware is defined in the dynamic configuration from the provider `docker`, meaning here in the labels section.

`traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https`
* The middleware `redirect-to-https` should use the pre-defined `redirectscheme` `https`

And that's it for the HTTPS redirection. We now have completed the configuration of Traefik in our `docker-compose.yml`.

##### Mastodon

We wanted to do something meaningful over just firing up Traefik, remember? The rest of our [docker-compose.yml](https://gist.github.com/smashnet/38cf7c30cb06427bab78ae5ab0fd2ae3) is composed of services required by Mastodon. I won't go into detail here. The part worth looking at are the services `web` and `streaming` as those must be accessible from the outside and hence need configuration for Traefik. We need `web` to deliver a nice UI for using Mastodon, and we need `streaming` to realize all the inter instance communication.

Luckily, the Traefik configuration is straight forward for both services and we know all the required parts from the labels setting up the Traefik dashboard.

###### Web

```
[...]
  web:
    [...]
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mastodon-web.rule=Host(`<DOMAIN>`)"
      - "traefik.http.routers.mastodon-web.entrypoints=websecure"
      - "traefik.http.routers.mastodon-web.tls.certresolver=letsencrypt"
[...]
```

You might recognize these labels, so I will just decribe in a few words what they do:

* We want the service `web` to be accessible through Traefik
* We create a router `mastodon-web` with a `rule` that lets the router react on requests coming in on your `<DOMAIN>`
* The router should only listen on the entrypoint `websecure` (port 443)
    * Requests to `http://<DOMAIN>` (without `s`) are redirected to the `websecure` endpoint by our HTTPS redirection router and middleware defined in the `traefik` labels section, remember?
* If not already existing, we want to use the certificate resolver `letsencrypt` to acquire or renew the TLS certificate

###### Streaming

```
[...]
  streaming:
    [...]
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mastodon-streaming.rule=(Host(`<DOMAIN>`) && PathPrefix(`/api/v1/streaming`))"
      - "traefik.http.routers.mastodon-streaming.entrypoints=websecure"
      - "traefik.http.routers.mastodon-streaming.tls.certresolver=letsencrypt"
[...]
```

For Mastodons streaming service this is very similar, let's see:

* We want the service `streaming` to be accessible through Traefik
* We create a router `mastodon-streaming` with a `rule` that lets the router react on requests coming in on your `<DOMAIN>` AND have a path that starts with `/api/v1/streaming`
* The router should only listen on the entrypoint `websecure` (port 443)
* If not already existing, we want to use the certificate resolver `letsencrypt` to acquire or renew the TLS certificate

### Conclusion

I was not quite happy with the assumptions made by Mastodon regarding instance setup. Especially, that they make instance admins go through a hell of nginx configuration. My goal was to make the process of setting up a new Mastodon instance as easy as possible. The solution is the combination of Mastodon with Traefik instead of Nginx and a self-contained [docker-compose.yml](https://gist.github.com/smashnet/38cf7c30cb06427bab78ae5ab0fd2ae3) that sets up everything necessary.

I sincerely hope this guide is useful for other upcoming Mastodon admins or Traefik fans :)

