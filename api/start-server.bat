@echo off
set MONGO_URI=mongodb+srv://ankush:ankush66@cluster0.wvivwbg.mongodb.net/konnect?retryWrites=true&w=majority&appName=Cluster0
set JWT_SECRET=konnect_dev_secret_key_2024
set PUBLIC_URL=http://localhost:4000
set INSTAGRAM_CLIENT_ID=demo_client_id
set INSTAGRAM_CLIENT_SECRET=demo_client_secret
set FACEBOOK_CLIENT_ID=demo_client_id
set FACEBOOK_CLIENT_SECRET=demo_client_secret
set OPENROUTER_API_KEY=
set OPENROUTER_MODEL=meta-llama/llama-3.2-1b-instruct:free
npm run dev:tsx