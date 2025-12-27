import uvicorn
import os
from dotenv import load_dotenv

# Load Env
load_dotenv()

if __name__ == "__main__":
    # Ensure necessary directories exist
    os.makedirs("outputs", exist_ok=True)
    
    uvicorn.run("api:app", host="0.0.0.0", port=8000, reload=True)
