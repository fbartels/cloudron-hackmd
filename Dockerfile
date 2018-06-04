FROM cloudron/base:0.11.0

# setup nodejs version
ENV NODEJS_VERSION 8.10.3
ENV NODE_ENV=production
RUN ln -s /usr/local/node-$NODEJS_VERSION/bin/node /usr/local/bin/node && \
    ln -s /usr/local/node-$NODEJS_VERSION/bin/npm /usr/local/bin/npm

RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn

WORKDIR /app/code

ENV HACKMD_VERSION 1.1.1-ce
RUN curl -L https://github.com/hackmdio/hackmd/archive/$HACKMD_VERSION.tar.gz | tar -xz --strip-components 1 -f -

# Install NPM dependencies and build project
RUN yarn install --pure-lockfile && \
    yarn install --production=false --pure-lockfile && \
    yarn global add webpack && \
    npm run build && \

# npm, deps
#RUN npm install

# build front-end bundle
#RUN npm run build

# remove dev dependencies
RUN npm prune --production

# add utils
ADD start.sh ./
RUN chmod +x ./start.sh

# use local storage
RUN ln -sfn /app/data/build/constant.js ./public/build/constant.js && \
    rm -rf ./public/uploads && ln -sf /app/data/uploads ./public/uploads

EXPOSE 3000

CMD ["/app/code/start.sh"]
