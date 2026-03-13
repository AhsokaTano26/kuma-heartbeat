package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
)

func main() {
	// 获取环境变量
	url := os.Getenv("UPTIME_KUMA_URL")
	intervalStr := os.Getenv("INTERVAL_MINUTES")

	if url == "" {
		log.Fatal("错误: 请设置环境变量 UPTIME_KUMA_URL")
	}

	interval, err := strconv.Atoi(intervalStr)
	if err != nil || interval <= 0 {
		interval = 5 // 默认 5 分钟
	}

	fmt.Printf("🚀 启动心跳服务\n目标: %s\n频率: 每 %d 分钟一次\n", url, interval)

	client := &http.Client{
		Timeout: 15 * time.Second,
		// 默认会跟随最多 10 个跳转，足以处理 302
	}

	for {
		resp, err := client.Get(url)
		currentTime := time.Now().Format("2006-01-02 15:04:05")

		if err != nil {
			fmt.Printf("[%s] ❌ 请求失败: %v\n", currentTime, err)
		} else {
			fmt.Printf("[%s] ✅ 响应状态: %s\n", currentTime, resp.Status)
			resp.Body.Close()
		}

		time.Sleep(time.Duration(interval) * time.Minute)
	}
}
