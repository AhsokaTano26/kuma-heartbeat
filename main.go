package main

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"
)

func main() {
	url := os.Getenv("UPTIME_KUMA_URL")
	intervalStr := os.Getenv("INTERVAL_MINUTES")

	if url == "" {
		fmt.Println("错误: 未设置 UPTIME_KUMA_URL")
		os.Exit(1)
	}

	interval, _ := strconv.Atoi(intervalStr)
	if interval <= 0 {
		interval = 5
	}

	// 增加超时到 30s，并禁用 Keep-Alives 避免连接池失效
	client := &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			DisableKeepAlives: true,
		},
	}

	fmt.Printf("🚀 强化版心跳启动 | 间隔: %dmin\n", interval)

	for {
		currentTime := time.Now().Format("2006-01-02 15:04:05")
		
		// 最多重试 3 次
		success := false
		for i := 1; i <= 3; i++ {
			resp, err := client.Get(url)
			if err == nil {
				fmt.Printf("[%s] ✅ 成功 (尝试 %d/3): %s\n", currentTime, i, resp.Status)
				resp.Body.Close()
				success = true
				break
			}
			fmt.Printf("[%s] ⚠️ 失败 (尝试 %d/3): %v\n", currentTime, i, err)
			time.Sleep(5 * time.Second) // 重试间隔
		}

		if !success {
			fmt.Printf("[%s] ❌ 本轮汇报彻底失败\n", currentTime)
		}

		time.Sleep(time.Duration(interval) * time.Minute)
	}
}
