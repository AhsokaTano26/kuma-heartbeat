# 阶段 1: 编译
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY main.go .
# 禁用 CGO 以获得静态二进制文件
RUN CGO_ENABLED=0 GOOS=linux go build -o heartbeat main.go

# 阶段 2: 运行
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/heartbeat .

ENV UPTIME_KUMA_URL=""
ENV INTERVAL_MINUTES="5"

CMD ["./heartbeat"]