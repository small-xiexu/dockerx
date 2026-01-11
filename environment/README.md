# Docker 中间件环境配置

本项目提供了一套完整的微服务开发环境，包含 20 个常用中间件服务，所有服务运行在同一个 Docker 网络中，便于服务间通信。

## 📋 目录

- [快速开始](#快速开始)
- [Docker 基础知识](#docker-基础知识)
- [网络配置](#网络配置)
- [服务列表](#服务列表)
- [端口映射表](#端口映射表)
- [目录结构](#目录结构)
- [服务详细配置](#服务详细配置)

---

## 🚀 快速开始

### 前置要求
- Docker Desktop for Mac 或 OrbStack
- 至少 8GB 可用内存

> **💡 提示**：本项目支持 Docker Desktop 和 OrbStack。OrbStack 是一个更轻量、更快速的 Docker 替代方案，推荐 Mac 用户使用。

### 启动所有服务
```bash
cd /path/to/environment
docker-compose -f docker-compose-light.yml up -d
```

### 启动指定服务
```bash
# 启动 MySQL 和 Redis
docker-compose -f docker-compose-light.yml up -d mysql redis

# 启动 Nacos（会自动启动依赖的 MySQL）
docker-compose -f docker-compose-light.yml up -d nacos
```

### 停止所有服务
```bash
docker-compose -f docker-compose-light.yml down
```

---

## 📚 Docker 基础知识

### 什么是 Docker 容器？

Docker 容器就像一个"虚拟的小电脑"，里面运行着一个独立的应用程序（比如 MySQL、Redis 等）。容器和你的 Mac 电脑是隔离的，互不影响。

**举个例子**：
- 你的 Mac 电脑 = 一栋大楼
- Docker 容器 = 大楼里的一个个独立房间
- 每个房间（容器）里运行着不同的服务（MySQL、Redis 等）

### 什么是挂载目录（Volume）？

**问题**：容器里的数据默认是临时的，容器删除后数据就丢失了。

**解决方案**：把容器里的目录"挂载"到你的 Mac 电脑上，这样数据就保存在你的电脑里了。

#### 挂载语法详解

```yaml
volumes:
  - ./data/db_data:/var/lib/mysql
```

**这行配置的含义**：

```
./data/db_data  :  /var/lib/mysql
     ↓                    ↓
  Mac 电脑的目录      容器内的目录
  （真实存储位置）    （MySQL 存数据的地方）
```

**通俗解释**：
1. **冒号左边** `./data/db_data`：
   - 这是你 Mac 电脑上的目录
   - `./` 表示当前项目目录（environment 文件夹）
   - 完整路径是：`/Users/你的用户名/dockerx/environment/data/db_data`
   - 这是数据的**真实存储位置**

2. **冒号右边** `/var/lib/mysql`：
   - 这是容器内部的目录
   - MySQL 容器会把数据库文件存在这里
   - 但实际上，这个目录的内容会"映射"到你 Mac 上的 `./data/db_data`

**效果**：
- MySQL 容器以为自己把数据存在了 `/var/lib/mysql`
- 实际上数据被存到了你 Mac 的 `./data/db_data` 目录
- 即使删除容器，数据还在你的 Mac 上
- 重新启动容器，数据还能继续使用

#### 为什么要用相对路径（`./`）？

```yaml
# ✅ 推荐：相对路径
- ./data/db_data:/var/lib/mysql

# ❌ 不推荐：绝对路径
- /Users/xiexu/dockerx/environment/data/db_data:/var/lib/mysql
```

**原因**：
- 相对路径：项目可以在任何电脑上运行，只要把项目文件夹复制过去就行
- 绝对路径：只能在你的电脑上运行，换台电脑路径就不对了

#### 常见挂载类型

**1. 数据持久化**（最重要）
```yaml
- ./data/db_data:/var/lib/mysql          # MySQL 数据库文件
- ./data/rabbitmq:/var/lib/rabbitmq      # RabbitMQ 数据
- ./ollama_data:/root/.ollama            # Ollama 模型文件
```
**作用**：保存重要数据，容器删除后数据不丢失

**2. 配置文件挂载**
```yaml
- ./config/mysql/init:/docker-entrypoint-initdb.d/     # MySQL 初始化脚本
- ./config/elk/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
```
**作用**：方便修改配置，不用进入容器内部

**3. 日志文件挂载**
```yaml
- ./logs:/home/nacos/logs                # Nacos 日志
- ./data/rocketmq/logs:/home/rocketmq/logs
```
**作用**：方便查看日志，排查问题

### OrbStack 特别说明

如果你使用的是 OrbStack（而不是 Docker Desktop），有以下优势：

1. **更快的启动速度**：OrbStack 比 Docker Desktop 启动快 2-3 倍
2. **更低的资源占用**：内存和 CPU 占用更少
3. **更好的文件系统性能**：挂载目录的读写速度更快
4. **完全兼容**：所有 Docker 命令和配置都可以直接使用

**使用方法完全相同**：
```bash
# 在 OrbStack 中使用相同的命令
docker-compose -f docker-compose-light.yml up -d
```

### 数据目录位置

所有挂载的数据都在项目目录下：

```
environment/
├── data/              # 数据持久化目录
│   ├── db_data/      # ← MySQL 数据在这里
│   ├── rabbitmq/     # ← RabbitMQ 数据在这里
│   └── rocketmq/     # ← RocketMQ 数据在这里
├── logs/              # ← Nacos 日志在这里
└── ollama_data/       # ← Ollama 模型在这里
```

**查看数据**：
```bash
# 进入项目目录
cd /Users/你的用户名/dockerx/environment

# 查看 MySQL 数据文件
ls -la data/db_data/

# 查看 Nacos 日志
ls -la logs/
```

---

## 🌐 网络配置

所有服务运行在 **`binghe-network`** 外部网络中，确保服务间可以通过容器名称互相访问。

```yaml
networks:
  binghe-network:
    name: binghe-network
    external: true
```

**注意**：首次使用前需要创建网络：
```bash
docker network create binghe-network
```

---

## 📦 服务列表

### 数据库 & 缓存
- **MySQL 8.0.32** - 关系型数据库
- **Redis Alpine 3.21** - 内存数据库
- **Vector DB (pgvector)** - 向量数据库（用于 AI 应用）

### 注册中心 & 配置中心
- **Nacos 2.3.1** - 服务注册与配置管理

### 消息队列
- **RocketMQ 5.3.1** - 分布式消息队列（NameServer + Broker + Console）
- **RabbitMQ 3.12.0** - 消息中间件

### 日志 & 监控
- **Elasticsearch 7.14.2** - 搜索引擎
- **Logstash 7.14.2** - 日志收集
- **Kibana 7.14.2** - 日志可视化
- **Prometheus 2.47.2** - 监控数据采集
- **Grafana 10.2.0** - 监控可视化
- **Sentinel** - 流量控制

### 分布式事务 & 任务调度
- **Seata Server 1.7.1** - 分布式事务
- **XXL-Job 2.4.0** - 分布式任务调度

### 数据同步
- **Canal Server 1.1.7** - MySQL binlog 解析
- **Canal Adapter 1.1.6** - 数据同步适配器

### 协调服务
- **Zookeeper 3.9.0** - 分布式协调服务

### AI 服务
- **Ollama 0.5.10** - 本地大语言模型服务

---

## 🔌 端口映射表

| 服务 | 端口 | 访问地址 | 默认账号密码 |
|------|------|----------|--------------|
| MySQL | 3306 | localhost:3306 | root/root |
| Redis | 6379 | localhost:6379 | - |
| Nacos | 8848, 9848, 9849 | http://localhost:8848/nacos | nacos/nacos |
| RocketMQ NameServer | 9876 | localhost:9876 | - |
| RocketMQ Broker | 10909, 10911, 10912 | - | - |
| RocketMQ Console | 19876 | http://localhost:19876 | - |
| RabbitMQ | 5672, 15672 | http://localhost:15672 | admin/admin |
| Elasticsearch | 9200, 9300 | http://localhost:9200 | - |
| Logstash | 5044, 5001, 9600 | - | - |
| Kibana | 5601 | http://localhost:5601 | - |
| Sentinel | 8858 | http://localhost:8858 | sentinel/sentinel |
| XXL-Job | 9090 | http://localhost:9090/xxl-job-admin | admin/123456 |
| Seata Server | 7091, 8091 | localhost:8091 | - |
| Zookeeper | 2181 | localhost:2181 | - |
| Prometheus | 9090 | http://localhost:9090 | - |
| Grafana | 4000 | http://localhost:4000 | admin/admin |
| Canal Server | 11111 | localhost:11111 | - |
| Canal Adapter | 8082 | http://localhost:8082 | - |
| Ollama | 11434 | http://localhost:11434 | - |
| Vector DB | 5432 | localhost:5432 | postgres/postgres |

---

## 📁 目录结构

```
environment/
├── .gitignore                      # Git 忽略规则
├── docker-compose-light.yml        # Docker Compose 配置文件
├── README.md                       # 本文档
│
├── canal/                          # Canal Server 配置
│   └── instance.properties         # Canal 实例配置
│
├── canal-adapter/                  # Canal Adapter 配置
│   ├── application.yml             # 应用配置
│   └── es7/                        # Elasticsearch 7 适配器配置
│
├── config/                         # 各服务配置文件
│   ├── elk/                        # ELK 配置
│   │   ├── elasticsearch.yml
│   │   ├── logstash.yml
│   │   ├── kibana.yml
│   │   └── pipeline/               # Logstash 管道配置
│   ├── mysql/                      # MySQL 配置
│   │   └── init/                   # 初始化 SQL 脚本
│   ├── nacos/                      # Nacos 配置
│   ├── pgvector/                   # Vector DB 配置
│   │   └── sql/init.sql            # 初始化脚本
│   ├── rocketmq/                   # RocketMQ 配置
│   │   └── broker.conf             # Broker 配置
│   └── seata/                      # Seata 配置
│       └── resources/              # Seata 资源文件
│
├── etc/                            # Prometheus & Grafana 配置
│   ├── prometheus/
│   │   └── prometheus.yml
│   └── grafana/
│
├── data/                           # 数据持久化目录（不提交到 Git）
│   ├── db_data/                    # MySQL 数据
│   ├── rocketmq/                   # RocketMQ 数据
│   │   ├── logs/
│   │   └── store/
│   └── rabbitmq/                   # RabbitMQ 数据
│
├── logs/                           # 日志文件（不提交到 Git）
│
└── ollama_data/                    # Ollama 模型数据（不提交到 Git）
```

**说明**：
- ✅ **应该提交到 Git**：配置文件（`config/`, `canal/`, `etc/` 等）
- ❌ **不应该提交到 Git**：数据文件（`data/`, `logs/`, `ollama_data/`）

---

## 🔧 服务详细配置

### 1. MySQL 8.0.32

**镜像**：`mysql:8.0.32`
**容器名**：`mysql`
**端口**：`3306:3306`

**环境变量**：
- `MYSQL_ROOT_PASSWORD`: root

**启动参数**：
- `--character-set-server=utf8mb4` - 字符集
- `--collation-server=utf8mb4_unicode_ci` - 排序规则
- `--default-time-zone=+8:00` - 时区（东八区）
- `--default-authentication-plugin=mysql_native_password` - 认证插件

**挂载目录**：
- `./data/db_data:/var/lib/mysql` - 数据持久化
- `./config/mysql/init:/docker-entrypoint-initdb.d/` - 初始化脚本

**依赖服务**：无

---

### 2. Redis Alpine 3.21

**镜像**：`redis:alpine3.21`
**容器名**：`redis`
**端口**：`6379:6379`

**环境变量**：无
**挂载目录**：无
**依赖服务**：无

---

### 3. Nacos 2.3.1

**镜像**：`nacos/nacos-server:v2.3.1-slim`
**容器名**：`nacos`
**端口**：`8848:8848`, `9848:9848`, `9849:9849`

**环境变量**：
- `TZ`: Asia/Shanghai - 时区
- `MODE`: standalone - 单机模式
- `SPRING_DATASOURCE_PLATFORM`: mysql - 数据源类型
- `MYSQL_SERVICE_HOST`: mysql - MySQL 主机
- `MYSQL_SERVICE_PORT`: 3306 - MySQL 端口
- `MYSQL_SERVICE_USER`: root - MySQL 用户
- `MYSQL_SERVICE_PASSWORD`: root - MySQL 密码
- `MYSQL_SERVICE_DB_NAME`: nacos_config - 数据库名
- `NACOS_AUTH_ENABLE`: true - 启用鉴权
- `NACOS_AUTH_IDENTITY_KEY`: nacos - 身份标识
- `NACOS_AUTH_IDENTITY_VALUE`: nacos - 身份值
- `JVM_XMS`: 256m - JVM 初始堆内存
- `JVM_XMX`: 256m - JVM 最大堆内存

**资源限制**：
- 内存限制：386M

**挂载目录**：
- `./logs:/home/nacos/logs` - 日志目录
- `./data:/home/nacos/data` - 数据目录

**依赖服务**：mysql

**访问地址**：http://localhost:8848/nacos
**默认账号**：nacos/nacos

---

### 4. RocketMQ 5.3.1

#### 4.1 RocketMQ NameServer

**镜像**：`apache/rocketmq:5.3.1`
**容器名**：`rmqnamesrv`
**端口**：`9876:9876`

**启动命令**：`sh mqnamesrv`

**挂载目录**：
- `./data/rocketmq/logs:/home/rocketmq/logs` - 日志
- `./data/rocketmq/store:/home/rocketmq/store` - 数据存储

**依赖服务**：无

#### 4.2 RocketMQ Broker

**镜像**：`apache/rocketmq:5.3.1`
**容器名**：`rmqbroker`
**端口**：`10909:10909`, `10911:10911`, `10912:10912`

**启动命令**：`sh mqbroker -n rmqnamesrv:9876 -c ../conf/broker.conf`

**环境变量**：
- `JAVA_HOME`: /usr/lib/jvm/jre

**挂载目录**：
- `./data/rocketmq/logs:/home/rocketmq/logs` - 日志
- `./data/rocketmq/store:/home/rocketmq/store` - 数据存储
- `./config/rocketmq/broker.conf:/home/rocketmq/rocketmq-5.3.1/conf/broker.conf` - Broker 配置

**依赖服务**：rmqnamesrv

#### 4.3 RocketMQ Console

**镜像**：`candice0630/rocketmq-console-ng:2.0`
**容器名**：`rocketmqConsole`
**端口**：`19876:8080`

**环境变量**：
- `JAVA_OPTS`: `-Drocketmq.namesrv.addr=rmqnamesrv:9876`

**依赖服务**：rmqnamesrv

**访问地址**：http://localhost:19876

---

### 5. RabbitMQ 3.12.0

**镜像**：`rabbitmq:3.12.0-management`
**容器名**：`rabbitmq`
**端口**：`5672:5672` (AMQP), `15672:15672` (管理界面)

**环境变量**：
- `RABBITMQ_DEFAULT_USER`: admin
- `RABBITMQ_DEFAULT_PASS`: admin

**挂载目录**：
- `./data/rabbitmq:/var/lib/rabbitmq` - 数据持久化

**依赖服务**：无

**访问地址**：http://localhost:15672
**默认账号**：admin/admin

---

### 6. ELK Stack 7.14.2

#### 6.1 Elasticsearch

**镜像**：`elasticsearch:7.14.2`
**容器名**：`elasticsearch`
**端口**：`9200:9200`, `9300:9300`

**环境变量**：
- `ES_JAVA_OPTS`: -Xmx256m -Xms256m - JVM 内存
- `discovery.type`: single-node - 单节点模式

**挂载目录**：
- `./config/elk/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml`

**依赖服务**：无

#### 6.2 Logstash

**镜像**：`logstash:7.14.2`
**容器名**：`logstash`
**端口**：`5044:5044`, `5001:5000`, `9600:9600`

**环境变量**：
- `LS_JAVA_OPTS`: -Xmx256m -Xms256m

**挂载目录**：
- `./config/elk/logstash.yml:/usr/share/logstash/config/logstash.yml`
- `./config/elk/pipeline:/usr/share/logstash/pipeline`

**依赖服务**：elasticsearch

#### 6.3 Kibana

**镜像**：`kibana:7.14.2`
**容器名**：`kibana`
**端口**：`5601:5601`

**挂载目录**：
- `./config/elk/kibana.yml:/usr/share/kibana/config/kibana.yml`

**依赖服务**：elasticsearch

**访问地址**：http://localhost:5601

---

### 7. Sentinel

**镜像**：`bladex/sentinel-dashboard:latest`
**容器名**：`sentinel`
**端口**：`8858:8858`

**依赖服务**：无

**访问地址**：http://localhost:8858
**默认账号**：sentinel/sentinel

---

### 8. XXL-Job 2.4.0

**镜像**：`kuschzzp/xxl-job-aarch64:2.4.0` (支持 ARM 架构)
**容器名**：`xxl-job-admin`
**端口**：`9090:9090`

**环境变量**：
- `SPRING_DATASOURCE_URL`: jdbc:mysql://mysql:3306/xxl_job?...
- `SPRING_DATASOURCE_USERNAME`: root
- `SPRING_DATASOURCE_PASSWORD`: root
- `SERVER_PORT`: 9090

**依赖服务**：mysql

**访问地址**：http://localhost:9090/xxl-job-admin
**默认账号**：admin/123456

---

### 9. Seata Server 1.7.1

**镜像**：`seataio/seata-server:1.7.1-slim`
**容器名**：`seata-server`
**端口**：`7091:7091`, `8091:8091`

**环境变量**：
- `SEATA_IP`: seata-server
- `SEATA_PORT`: 8091

**挂载目录**：
- `/usr/share/zoneinfo/Asia/Shanghai:/etc/localtime` - 系统时区
- `/usr/share/zoneinfo/Asia/Shanghai:/etc/timezone` - 时区配置
- `./config/seata/resources:/seata-server/resources` - Seata 配置

**依赖服务**：mysql, nacos

---

### 10. Zookeeper 3.9.0

**镜像**：`zookeeper:3.9.0`
**容器名**：`zookeeper`
**端口**：`2181:2181`

**环境变量**：
- `ZOO_MY_ID`: 1
- `ZOO_SERVERS`: server.1=zookeeper:2888:3888;2181

**依赖服务**：无

---

### 11. Prometheus 2.47.2

**镜像**：`bitnami/prometheus:2.47.2`
**容器名**：`prometheus`
**端口**：`9090:9090`

**挂载目录**：
- `./etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml`

**依赖服务**：无

**访问地址**：http://localhost:9090

---

### 12. Grafana 10.2.0

**镜像**：`grafana/grafana:10.2.0`
**容器名**：`grafana`
**端口**：`4000:4000`

**挂载目录**：
- `./etc/grafana:/etc/grafana`

**依赖服务**：prometheus

**访问地址**：http://localhost:4000
**默认账号**：admin/admin

---

### 13. Canal Server 1.1.7

**镜像**：`canal/canal-server:v1.1.7`
**容器名**：`canal-server`
**端口**：`11111:11111`

**挂载目录**：
- `./canal/instance.properties:/home/admin/canal-server/conf/example/instance.properties`

**依赖服务**：mysql

**说明**：Canal 伪���成 MySQL 的从库，实时解析 binlog

---

### 14. Canal Adapter 1.1.6

**镜像**：`coopersoft/canal-adapter:v1.1.6`
**容器名**：`canal-adapter`
**端口**：`8082:8081`

**挂载目录**：
- `./canal-adapter/application.yml:/opt/canal-adapter/conf/application.yml`
- `./canal-adapter/es7:/opt/canal-adapter/conf/es7`

**依赖服务**：canal-server

**说明**：负责将 Canal 解析的数据同步到目标系统（如 Elasticsearch）

---

### 15. Ollama 0.5.10

**镜像**：`ollama/ollama:0.5.10`
**容器名**：`ollama`
**端口**：`11434:11434`

**挂载目录**：
- `./ollama_data:/root/.ollama` - 模型数据存储

**依赖服务**：无

**访问地址**：http://localhost:11434

**说明**：本地大语言模型服务，支持运行 Llama、Mistral 等开源模型

---

### 16. Vector DB (pgvector)

**镜像**：`pgvector/pgvector:pg16`
**容器名**：`vector_db`
**端口**：`5432:5432`

**环境变量**：
- `POSTGRES_USER`: postgres
- `POSTGRES_PASSWORD`: postgres
- `POSTGRES_DB`: springai
- `PGPASSWORD`: postgres

**挂载目录**：
- `./config/pgvector/sql/init.sql:/docker-entrypoint-initdb.d/init.sql`

**健康检查**：
- 命令：`pg_isready -U postgres -d springai`
- 间隔：2s
- 超时：20s
- 重试：10 次

**日志配置**：
- 最大文件大小：10m
- 最大文件数：3

**依赖服务**：无

**说明**：PostgreSQL + pgvector 扩展，用于存储和检索向量数据（AI 应用）

---

## 📝 使用说明

### 1. 首次使用

```bash
# 1. 创建网络
docker network create binghe-network

# 2. 启动所有服务
docker-compose -f docker-compose-light.yml up -d

# 3. 查看服务状态
docker-compose -f docker-compose-light.yml ps
```

### 2. 常用命令

```bash
# 查看服务日志
docker-compose -f docker-compose-light.yml logs -f [服务名]

# 重启服务
docker-compose -f docker-compose-light.yml restart [服务名]

# 停止服务
docker-compose -f docker-compose-light.yml stop [服务名]

# 删除服务（保留数据）
docker-compose -f docker-compose-light.yml down

# 删除服务及数据卷
docker-compose -f docker-compose-light.yml down -v
```

### 3. 服务依赖关系

```
MySQL
├── Nacos
│   └── Seata Server
├── XXL-Job Admin
└── Canal Server
    └── Canal Adapter

RocketMQ NameServer
├── RocketMQ Broker
└── RocketMQ Console

Elasticsearch
├── Logstash
└── Kibana

Prometheus
└── Grafana
```

### 4. 数据备份

重要数据目录：
- `./data/db_data/` - MySQL 数据
- `./data/rocketmq/` - RocketMQ 数据
- `./data/rabbitmq/` - RabbitMQ 数据
- `./ollama_data/` - Ollama 模型

建议定期备份这些目录。

### 5. 配置修改

修改配置文件后需要重启对应服务：
```bash
docker-compose -f docker-compose-light.yml restart [服务名]
```

### 6. 日志管理

#### 日志文件位置
- `./logs/` - Nacos 日志（247MB+）
- `./data/rocketmq/logs/` - RocketMQ 日志

#### 自动清理日志（推荐）

**方法 1：手动清理**
```bash
# 清理超过 30 天的日志文件
./clean-logs.sh
```

**方法 2：设置自动定时清理（每天凌晨 3 点）**
```bash
# 1. 复制配置文件到 LaunchAgents 目录
cp com.docker.environment.cleanlogs.plist ~/Library/LaunchAgents/

# 2. 加载定时任务
launchctl load ~/Library/LaunchAgents/com.docker.environment.cleanlogs.plist

# 3. 查看任务状态
launchctl list | grep cleanlogs

# 4. 如需停止自动清理
launchctl unload ~/Library/LaunchAgents/com.docker.environment.cleanlogs.plist
```

**方法 3：立即清理所有旧日志**
```bash
# 清理 logs 目录中所有 .log.* 文件（保留当前日志）
find ./logs -name "*.log.*" -type f -delete

# 清理 RocketMQ 日志
find ./data/rocketmq/logs -name "*.log.*" -type f -delete
```

#### 查看日志大小
```bash
# 查看 logs 目录大小
du -sh ./logs

# 查看各个日志文件大小
du -sh ./logs/* | sort -hr | head -20
```

---

## ⚠️ 注意事项

1. **内存要求**：建议至少 8GB 可用内存，部分服务（如 Elasticsearch）对内存要求较高
2. **端口冲突**：确保所有端口未被占用
3. **数据持久化**：`data/` 目录包含所有持久化数据，请勿删除
4. **生产环境**：本配置适用于开发环境，生产环境需要调整安全配置（如密码、JVM 参数等）
5. **ARM 架构**：XXL-Job 使用了支持 ARM 的镜像，适配 M1/M2 Mac

---

## 🔗 相关链接

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Nacos 文档](https://nacos.io/zh-cn/docs/quick-start.html)
- [RocketMQ 文档](https://rocketmq.apache.org/docs/quick-start/)
- [Seata 文档](https://seata.io/zh-cn/docs/overview/what-is-seata.html)

---

## 📄 License

本项目仅供学习和开发使用。
