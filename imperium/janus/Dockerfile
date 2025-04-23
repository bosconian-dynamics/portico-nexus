ARG NODE_VERSION=22
ARG PNPM_CACHE_TYPE=cache

###
# Base stage
#
# Caches production dependencies.
###
FROM node:${NODE_VERSION}-alpine AS base

ARG PNPM_CACHE_TYPE

WORKDIR /app

RUN corepack enable
COPY --link package.json pnpm-lock.yaml ./
RUN --mount=type=${PNPM_CACHE_TYPE},id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

###
# Build stage
#
# Installs dev dependencies and builds the app.
###
FROM base AS build

WORKDIR /app

COPY --link . .
RUN --mount=type=${PNPM_CACHE_TYPE},id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

###
# Production stage
#
# Creates image from production dependencies and build output.
###
FROM node:${NODE_VERSION}-alpine AS production

ARG PORT=3000
ARG HOST=0.0.0.0
ARG NITRO_PRESET=node-server
ENV PORT=${PORT}
ENV HOST=${HOST}
ENV NITRO_PRESET=${NITRO_PRESET}

WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY --from=build /app/.output ./.output
COPY --from=build /app/package.json /app/pnpm-lock.yaml ./
# RUN pnpm prune --prod # Shouldn't be necessary given the mounted prod dep cache imported from the base stage.

EXPOSE ${PORT}
CMD ["node", ".output/server/index.mjs"]
