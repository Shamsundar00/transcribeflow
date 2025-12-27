import os
import google.generativeai as genai
from dotenv import load_dotenv

# Force load env check
load_dotenv(override=True)
api_key = os.getenv("GEMINI_API_KEY")

with open("available_models.txt", "w", encoding="utf-8") as f:
    f.write(f"Checking models for API Key: {api_key[:5]}...{api_key[-5:] if api_key else 'None'}\n\n")

    if not api_key:
        f.write("No API Key found!\n")
        exit(1)

    genai.configure(api_key=api_key)

    f.write("Listing available models...\n")
    try:
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                f.write(f"- {m.name}\n")
    except Exception as e:
        f.write(f"Error listing models: {e}\n")
