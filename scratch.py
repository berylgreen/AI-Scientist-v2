import os
import openai

client = openai.OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
    base_url=os.environ.get("OPENAI_BASE_URL", "https://chen.custom.tunecoder.com/v1")
)

try:
    response = client.chat.completions.create(
        model="gpt-5.3-codex",
        messages=[{"role": "user", "content": "Hello!"}]
    )
    print("Success:", response.choices[0].message.content)
except Exception as e:
    print("Exception details:")
    print(type(e).__name__, ":", str(e))
