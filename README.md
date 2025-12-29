# AI 编程助手

一个基于 DeepSeek API 和 LangChain 的智能编程助手，支持命令行界面 (CLI) 和 Web 界面两种使用方式。

## 功能特性

- 🧠 智能代码生成：根据用户需求生成高质量、可运行的 Python 代码
- 💬 会话管理：支持多轮对话，保持上下文记忆
- 🌐 双模式界面：CLI 命令行和 Web 浏览器界面
- 🔧 纯代码模式：可选择仅输出代码块，方便复制
- 🚀 简单部署：使用 Python 标准库，无需复杂框架

## 环境要求

- Python >= 3.9（推荐 3.10/3.11）
- pip 包管理器
- DeepSeek API 密钥

## 安装步骤

1. 克隆或下载项目文件到本地目录

2. 安装依赖包：

   ```bash
   pip install -r requirements.txt
   ```

3. 配置 API 密钥：
   编辑 `main.py` 文件，将 `DEEPSEEK_API_KEY` 变量设置为您的 DeepSeek API 密钥

## 使用方法

### 方式一：命令行界面 (CLI)

直接运行主程序：

```bash
python main.py
```

交互命令：

- 输入问题获取代码建议
- 输入 `exit` 退出程序
- 输入 `/pure` 切换纯代码模式

### 方式二：Web 界面

1. 启动本地服务器：

   ```bash
   python local_server.py
   ```

2. 打开浏览器访问：

   ```
   http://127.0.0.1:8765/static/index.html
   ```

   或使用提供的启动脚本：

   ```bash
   ./run.sh
   ```

## 项目结构

```
AI Assistant/
├── main.py              # CLI 版本主程序
├── local_server.py     # Web 服务器
├── static/
│   └── index.html       # Web 界面
├── requirements.txt     # Python 依赖
├── run.sh               # Linux/macOS 启动脚本
├── launch.bat           # Windows 启动脚本
└── README.md            # 项目说明
```

## 注意事项

- 请确保 API 密钥有效且有足够的使用额度
- Web 界面支持 CORS，可直接在浏览器中打开使用
- 建议在虚拟环境中运行以避免依赖冲突
- 项目使用 LangChain 1.x 版本，请勿与旧版本混用

## 许可证

本项目仅供学习和个人使用，请遵守相关 API 服务条款。
