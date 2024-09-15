FROM alpine:latest

# Emplacement de l'application
WORKDIR /app

# Install base packages
RUN apk update && \
  apk add --no-cache bash curl cron docker-cli nano yq tzdata \
  rm -rf /var/cache/apk/*

# Copier les fichiers dans le conteneur
COPY . .

# Rendre les scripts exécutables
RUN chmod +x bin/entrypoint.sh

ENTRYPOINT ["/app/bin/entrypoint.sh"]

CMD ["crond", "-f"]
