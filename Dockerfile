FROM node:lts-alpine3.18 as base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package.json ./
RUN apk update && \
    apk add --no-cache \
    vips-dev \
    fftw-dev \
    gcc \
    g++ \
    make \
    libc6-compat \
    && rm -rf /var/cache/apk/*
RUN npm install --production --pure-lockfile && \
    npm add sharp --ignore-engines && \
    npm cache clean

FROM base as build
WORKDIR /usr/src/wpp-server
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package.json  ./
RUN npm install --production=false --pure-lockfile
RUN npm cache clean
COPY . .
RUN npm run build

FROM base
WORKDIR /usr/src/wpp-server/
RUN apk add --no-cache chromium
RUN npm cache clean
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 3000
ENTRYPOINT ["node", "dist/server.js"]
