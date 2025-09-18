# Use this image to build your Jekyll site
FROM ruby:3-slim-bookworm AS jekyll

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile .

RUN gem update --system && gem install jekyll && gem cleanup
RUN bundle install --retry 5 --jobs 20

EXPOSE 4000

WORKDIR /site

ENTRYPOINT [ "jekyll" ]

CMD [ "--help" ]
