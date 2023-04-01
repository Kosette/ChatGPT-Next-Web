FROM node:lts-alpine AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --production


FROM node:lts-alpine AS builder

RUN apk update && apk add --no-cache git

ENV OPENAI_API_KEY=""
ENV CODE=""
ARG DOCKER=true

WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
COPY . .

RUN yarn build --prod


FROM node:lts-alpine AS runner
WORKDIR /app

ENV OPENAI_API_KEY=""
ENV CODE=""

COPY --from=builder /app/public /app/public
COPY --from=builder /app/.next/standalone /app
COPY --from=builder /app/.next/static /app/.next/static
COPY --from=builder /app/.next/server /app/.next/server

EXPOSE 3000

CMD ["node","server.js"]
