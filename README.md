# DockerX

Docker 开发环境配置仓库，提供微服务开发所需的各类中间件服务。

## 📁 项目结构

```
dockerx/
├── environment/          # Docker 中间件环境配置
│   ├── docker-compose-light.yml   # Docker Compose 配置
│   ├── README.md                  # 详细使用文档
│   ├── config/                    # 各服务配置文件
│   └── data/                      # 数据持久化目录
└── README.md             # 本文件
```

## 🚀 快速开始

```bash
# 1. 进入环境目录
cd environment

# 2. 创建 Docker 网络（首次使用）
docker network create binghe-network

# 3. 启动所有服务
docker-compose -f docker-compose-light.yml up -d
```

## 📦 包含的服务

| 分类 | 服务 |
|------|------|
| **数据库 & 缓存** | MySQL 8.0、Redis、PostgreSQL (pgvector) |
| **注册中心** | Nacos 2.3.1 |
| **消息队列** | RocketMQ 5.3.1、RabbitMQ 3.12 |
| **日志监控** | ELK Stack (Elasticsearch + Logstash + Kibana) |
| **监控可视化** | Prometheus + Grafana |
| **分布式事务** | Seata 1.7.1 |
| **任务调度** | XXL-Job 2.4.0 |
| **流量控制** | Sentinel |
| **数据同步** | Canal Server + Adapter |
| **AI 服务** | Ollama |

## 📖 详细文档

👉 **[查看完整使用文档](./environment/README.md)**

包含：
- 各服务的详细配置说明
- 端口映射表
- 数据持久化说明
- 常见问题解答

## ⚠️ 注意事项

- 建议至少 8GB 可用内存
- 本配置适用于 **开发环境**，生产环境需调整安全配置
- 支持 Docker Desktop 和 OrbStack (推荐 Mac 用户使用 OrbStack)

## 📄 License

本项目仅供学习和开发使用。
