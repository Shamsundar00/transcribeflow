# Beginner's Guide to Free Cloud Hosting

This guide will help you put your "Brain" (Backend) on the internet so your Mobile App works anywhere, without your computer needing to be on.

We will use **GitHub** (to store your code) and **Render** (a free server).

---

## Phase 1: Put Your Code on GitHub

1.  **Create a GitHub Account**
    *   Go to [github.com](https://github.com) and Sign Up (if you haven't already).

2.  **Create a New Repository**
    *   Log in to GitHub.
    *   Click the **+** icon in the top-right corner -> **New repository**.
    *   **Repository name**: `transcribeflow` (or anything you like).
    *   **Public/Private**: Choose **Public** (easier) or Private.
    *   Click **Create repository**.

3.  **Upload Your Code**
    *   Keep that GitHub page open! You will see a section called "…or create a new repository on the command line".
    *   Open your terminal (Command Prompt or PowerShell) on your computer.
    *   Make sure you are in your project folder:
        ```bash
        cd c:\FlutterProjects\Insta_transcription
        ```
    *   **Copy and Paste** these commands one by one:
        ```bash
        git init
        ```
        ```bash
        git add .
        ```
        ```bash
        git commit -m "Initial upload"
        ```
        ```bash
        git branch -M main
        ```
    *   **Crucial Step**: Look at your GitHub page. Copy the command that starts with `git remote add origin ...` and paste it into your terminal.
        *   Example: `git remote add origin https://github.com/YourName/transcribeflow.git`
    *   Finally, upload the code:
        ```bash
        git push -u origin main
        ```

---

## Phase 2: Create the Server on Render

1.  **Create a Render Account**
    *   Go to [dashboard.render.com](https://dashboard.render.com).
    *   Click **"Sign Up"** and choose **"Continue with GitHub"** (this is important!).
    *   Authorize Render to access your GitHub account.

2.  **Create a New Web Service**
    *   In the Render Dashboard, click the blue **"New +"** button.
    *   Select **"Web Service"**.
    *   You should see your `transcribeflow` repository in the list. Click **"Connect"**.

3.  **Configure the Server**
    *   **Name**: `transcribeflow-backend`
    *   **Region**: Choose the one closest to you (e.g., Singapore).
    *   **Root Directory**: `backend` (⚠️ **Very Important**: Type exactly `backend`).
    *   **Runtime**: Select **Docker** (It might auto-select this, which is good).
    *   **Instance Type**: Select **Free**.

4.  **Add Your Password (API Key)**
    *   Scroll down to the **"Environment Variables"** section.
    *   Click **"Add Environment Variable"**.
    *   **Key**: `GEMINI_API_KEY`
    *   **Value**: `AIzaSyCs8FF0pk3nIcSBAIJ7bzGI6bPZWE-g1TM`
    *   *(If you use OpenAI or others, add them here too).*

5.  **Launch!**
    *   Click **"Create Web Service"**.
    *   Wait about 3-5 minutes. Render is building your server.
    *   Once it says **"Live"** (green), look for your URL at the top.
    *   It will look like: `https://transcribeflow-backend.onrender.com`. **Copy this URL.**

---

## Phase 3: Connect Your Mobile App

1.  Open your Flutter App on your phone.
2.  Go to **Settings**.
3.  In the "Server URL" box, paste the URL you copied from Render.
    *   Example: `https://transcribeflow-backend.onrender.com`
4.  Click **SAVE CONFIGURATION**.

**You are done!** Your app is now fully independent and works globally.
