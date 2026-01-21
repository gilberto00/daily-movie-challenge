#!/bin/bash

# Script para fazer commit da correção da navegação
# Execute: chmod +x commit_navigation_fix.sh && ./commit_navigation_fix.sh

cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

echo "🔍 Verificando status do Git..."
git status

echo ""
echo "📦 Adicionando arquivos modificados..."
git add .

echo ""
echo "💾 Criando commit..."
git commit -m "fix: corrigir navegação do botão Back to Home

- HomeView agora controla a navegação através de callback
- TriviaView e ResultView usam callbacks para voltar para Home
- Adicionados logs de debug para facilitar troubleshooting
- Botão Back to Home funciona corretamente tanto no ResultView quanto na CommentsView"

echo ""
echo "📤 Fazendo push para GitHub..."
git push origin main

echo ""
echo "✅ Commit realizado com sucesso!"
