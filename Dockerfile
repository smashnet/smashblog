# Image to run the site
FROM nginx:1-bookworm

COPY _site/ /usr/share/nginx/html

