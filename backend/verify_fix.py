import asyncio
import os
import sys

# Add current directory to path so we can import core
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from core import TranscribeCore
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

async def main():
    print("Starting verification script...")
    # URL from screenshot
    url = "https://www.instagram.com/reel/DSxZAuIj9a5/?utm_source=ig_web_copy_link"
    
    # Initialize Core (will pick up env var)
    print("Initializing TranscribeCore...")
    try:
        core = TranscribeCore()
    except Exception as e:
        print(f"Failed to init core: {e}")
        return

    async def mock_callback(msg, level):
        print(f"[{level.upper()}] {msg}")

    try:
        print(f"Testing URL: {url}")
        result = await core.process_link(url, progress_callback=mock_callback)
        print("\nSUCCESS! Transcription completed.")
        print("Result Preview:", result.get("preview"))
        print("Files Generated:", result.get("files"))
    except Exception as e:
        print(f"\nFAILED with error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
