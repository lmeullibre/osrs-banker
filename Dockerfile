FROM node:18-alpine as build-ui
WORKDIR /app

EXPOSE 80

ARG VITE_DATABASE_URL
ENV VITE_DATABASE_URL=$VITE_DATABASE_URL

ARG VITE_APP_ID
ENV VITE_APP_ID=$VITE_APP_ID

ARG VITE_APP_API_KEY
ENV VITE_APP_API_KEY=$VITE_APP_API_KEY

COPY ui/*.json ui/.npmrc ./
RUN npm ci

COPY ui ./
RUN npm run build
RUN npm run check

FROM nginx:alpine-slim as final

ARG VERSION=dev
ENV VERSION=$VERSION

WORKDIR /app
COPY --from=build-ui /app/build ./
COPY nginx.conf /etc/nginx/nginx.conf

RUN echo "Setting built version to $VERSION" &&  \
    sed -Ei "s/\\\$VERSION/$VERSION/" index.html
