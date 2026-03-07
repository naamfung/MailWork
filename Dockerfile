#
# MailHog Dockerfile
#

FROM golang:1.24-alpine AS builder

# Install dependencies:
RUN apk --no-cache add --virtual build-dependencies \
    git

# Copy local code to the container:
WORKDIR /app
COPY . .

# Set GOPROXY to use Qiniu Cloud mirror for faster dependency download:
RUN go env -w GOPROXY=https://goproxy.cn,direct

# Build MailHog:
RUN go build -mod=mod -o mailhog .

FROM alpine:latest
# Add mailhog user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhog

COPY --from=builder /app/mailhog /usr/local/bin/

USER mailhog

WORKDIR /home/mailhog

ENTRYPOINT ["mailhog"]

# Expose the SMTP, IMAP and HTTP ports:
EXPOSE 1025 143 8025
