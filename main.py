import re
from typing import Dict

from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

# ====== 直接写死 Key（不使用环境变量） ======
DEEPSEEK_API_KEY = ""
DEEPSEEK_BASE_URL = "https://api.deepseek.com"
MODEL_NAME = "deepseek-chat"
# ============================================

SYSTEM_PROMPT = """
你是专业 AI 编程助手。
你的任务：根据用户需求生成高质量、可运行的代码。

要求：
1) 默认输出 Python 代码，除非用户指定其他语言
2) 代码要完整可运行，包含必要 import
3) 输出格式：先给 Markdown 代码块，再给不超过 5 行解释
4) 若需求不清晰，最多提出 2 个澄清问题
"""

def extract_code_block(md: str) -> str:
    m = re.search(r"```(?:\w+)?\n([\s\S]*?)```", md)
    return m.group(1).strip() if m else md.strip()

def build_assistant():
    llm = ChatOpenAI(
        model=MODEL_NAME,
        api_key=DEEPSEEK_API_KEY,
        base_url=DEEPSEEK_BASE_URL,
        temperature=0.2,
    )

    prompt = ChatPromptTemplate.from_messages([
        ("system", SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}")
    ])

    chain = prompt | llm

    # 为不同 session 保存不同的 chat history
    store: Dict[str, InMemoryChatMessageHistory] = {}

    def get_history(session_id: str) -> InMemoryChatMessageHistory:
        if session_id not in store:
            store[session_id] = InMemoryChatMessageHistory()
        return store[session_id]

    chain_with_history = RunnableWithMessageHistory(
        chain,
        get_history,
        input_messages_key="question",
        history_messages_key="history",
    )

    return chain_with_history

def main():
    if not DEEPSEEK_API_KEY or "填这里" in DEEPSEEK_API_KEY:
        raise ValueError("请先在 main.py 里填写 DEEPSEEK_API_KEY")

    assistant = build_assistant()

    print("\n==============================")
    print("🧠 AI 编程助手（LangChain 1.x / CLI）")
    print("输入 exit 退出；输入 /pure 只显示纯代码")
    print("==============================\n")

    session_id = "default"
    pure_mode = False

    while True:
        q = input("你：").strip()
        if not q:
            continue
        if q.lower() == "exit":
            break

        if q == "/pure":
            pure_mode = not pure_mode
            print(f"✅ 纯代码模式：{pure_mode}\n")
            continue

        res = assistant.invoke(
            {"question": q},
            config={"configurable": {"session_id": session_id}}
        )

        text = res.content

        print("\n--- AI 输出 ---\n")
        if pure_mode:
            print(extract_code_block(text))
        else:
            print(text)
        print("\n")

if __name__ == "__main__":
    main()
