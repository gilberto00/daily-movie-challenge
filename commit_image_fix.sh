#!/bin/bash

# Script para fazer commit da correção do carregamento de imagens
# Execute: chmod +x commit_image_fix.sh && ./commit_image_fix.sh

cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

echo "📦 Adicionando arquivos modificados..."
git add .

echo "💾 Criando commit..."
git commit -m "fix: corrigir carregamento de imagens e remover logs de debug

- Substituído AsyncImage por URLSession manual para evitar cancelamentos (-999)
- Implementado componente MoviePosterImageView com controle de estado
- Adicionado cache automático de imagens
- Melhorado tratamento de erros com botão de retry
- Removidas todas as mensagens de debug (print statements e textos DEBUG)
- Corrigido onChange para usar sintaxe iOS 17+
- Adicionada conformidade Equatable ao modelo DailyChallenge"

echo "📤 Fazendo push para o GitHub..."
git push origin main

echo "✅ Commit e push concluídos!"
