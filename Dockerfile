FROM node:14 AS builder

WORKDIR /usr/src/app

COPY package*.json ./

COPY . .

RUN yarn && yarn build

# Node alpine for minimal production footprint
FROM node:14-alpine as production

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/index.js ./
COPY --from=builder /usr/src/app/src ./src

ENTRYPOINT ["node"]

CMD ["index.js"]