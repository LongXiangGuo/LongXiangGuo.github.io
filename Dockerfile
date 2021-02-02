FROM jekyll/jekyll:stable

RUN gem install bundler

COPY ./ /mobile20
WORKDIR /mobile20

RUN bundle install

ENTRYPOINT jekyll serve --config _config_local.yml