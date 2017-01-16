FROM node:6.9.1

RUN useradd --user-group --create-home --shell /bin/false app

ENV HOME=/home/app
ENV APP=service1
ENV NPM_CONFIG_LOGLEVEL warn

# Copy package.json and dependencies, and run npm install before adding
# the rest of the files. This way, you only run npm install when
# package.json changes.
COPY ./package.json $HOME/$APP/package.json
COPY ./my-npm $HOME/$APP/my-npm
RUN chown -R app:app $HOME/*

# install deps as a separate step so it gets cached independently of code.
USER app
WORKDIR $HOME/$APP
RUN npm install && npm cache clean

# This COPY excludes node_modules thanks to .gitignore. We want to use
# the node_modules built by the above "npm install", which will be
# mounted as a volume on top of our host's app dir.  It is particularly
# important if any npm packages are built on top of native libraries.
# http://stackoverflow.com/a/39119254
USER root
COPY . $HOME/$APP
RUN chown -R app:app $HOME/*

# "eslint" fails without this
RUN chmod u+x ./node_modules/.bin/*

USER app

#ENTRYPOINT ["/home/app/service1/bin/entrypoint.sh"]
CMD ["npm", "run", "start:dev"]
