# mongodb@7 memerlukan Node >= 20.19, jadi guna Node 22 LTS
FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .
RUN mkdir -p /app/uploads && chown -R node:node /app
USER node

EXPOSE 8001
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8001/api/health || exit 1

CMD ["node", "server.js"]
