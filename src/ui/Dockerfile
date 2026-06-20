FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts && npm cache clean --force
COPY . .
RUN npm run build
FROM node:22-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
ENV PORT=8080
USER appuser
EXPOSE 8080
CMD ["node", "dist/app.js"]