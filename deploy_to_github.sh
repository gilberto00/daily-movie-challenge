#!/bin/bash

# Script para fazer deploy do código para o GitHub
# Execute: chmod +x deploy_to_github.sh && ./deploy_to_github.sh

cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

echo "🚀 Inicializando Git..."
git init

echo "📦 Adicionando arquivos..."
git add .

echo "💾 Criando commit inicial..."
git commit -m "feat: first functional MVP with Firebase and TMDB"

echo "🌿 Configurando branch main..."
git branch -M main

echo "🔗 Conectando ao repositório remoto..."
git remote add origin https://github.com/gilberto00/daily-movie-challenge.git 2>/dev/null || git remote set-url origin https://github.com/gilberto00/daily-movie-challenge.git

echo "📤 Fazendo push para o GitHub..."
git push -u origin main

echo "✅ Concluído! Verifique em: https://github.com/gilberto00/daily-movie-challenge"
