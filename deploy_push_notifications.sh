#!/bin/bash

# Script para fazer deploy das Cloud Functions e regras do Firestore para Push Notifications
# Execute: chmod +x deploy_push_notifications.sh && ./deploy_push_notifications.sh

cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

echo "📦 Instalando dependências das Cloud Functions..."
cd functions
npm install
cd ..

echo "🚀 Fazendo deploy das regras do Firestore..."
npx firebase-tools deploy --only firestore:rules

echo "🚀 Fazendo deploy das Cloud Functions..."
npx firebase-tools deploy --only functions

echo "✅ Deploy completo!"
