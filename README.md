# AI 编程助手

基于 LangChain 1.x 与 DeepSeek API 的轻量级编程助理，支持命令行和本地 Web 页面两种形态，适合在本地快速生成可运行的 Python 代码。

## 功能亮点

- 🧠 多轮对话记忆：按 `session_id` 维护上下文
- 💻 双端体验：CLI 与浏览器 UI 同步支持
- 🧾 纯代码模式：一键切换只输出代码块
- 🌐 简易本地服务：内置 `/api/chat` HTTP 接口和 `/health` 检查
- 🛠️ 零外部框架：纯标准库 + LangChain 依赖即可运行

## 项目结构

```
AI Assistant/
├── main.py              # CLI 主程序，含模型配置与对话逻辑
├── local_server.py      # 简易 HTTP 服务，调用同一对话链
├── static/index.html    # 浏览器 UI（纯静态，可直开）
├── run.sh / launch.bat  # 快速启动脚本
├── requirements.txt     # 依赖清单
└── README.md
```

## 使用方法

```
launch.bat #Windows系统
```

```
run.sh #Linux和Macos
```

## 注意事项

启动脚本路径不要有中文
