FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install
COPY . .
RUN yarn build
FROM node:22-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn workspaces focus --production && yarn cache clean
COPY --from=builder /app/dist ./dist
USER appuser
EXPOSE 8080
CMD ["node", "dist/main.js"]
