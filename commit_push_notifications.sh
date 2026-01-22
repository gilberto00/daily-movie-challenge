#!/bin/bash

# Script para fazer commit das implementações do Item 7 - Push Notifications
# Execute: chmod +x commit_push_notifications.sh && ./commit_push_notifications.sh

cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

echo "📦 Adicionando arquivos modificados..."
git add .

echo "💾 Criando commit..."
git commit -m "feat: implementar Item 7 - Push Notifications (Sprint 2)

- Adicionado NotificationService.swift para gerenciar FCM tokens e permissões
- Adicionado modelo NotificationSettings para configurações de notificações
- Implementadas funções no FirestoreService para tokens FCM e settings
- Integrado setup FCM no DailyMovieChallengeApp.swift
- Adicionado FirebaseMessaging ao project.pbxproj
- Configurado Background Modes (remote-notification) no Info.plist
- Criadas 3 Cloud Functions:
  * sendDailyChallengeNotification - notificação diária às 9h
  * sendStreakReminderNotification - notificação de streak em risco às 20h
  * onBadgeAwarded - trigger para notificação de conquistas
- Atualizadas regras do Firestore para fcmTokens e notificationSettings
- Criados documentos de setup e instruções:
  * SETUP_PUSH_NOTIFICATIONS.md
  * ITEM_7_RESUMO_IMPLEMENTACAO.md
  * ADICIONAR_FIREBASE_MESSAGING.md
  * COMO_OBTER_CERTIFICADO_APNS.md
  * deploy_push_notifications.sh
- Corrigido layout do botão Submit no TriviaView usando .safeAreaInset
- Implementado layout adaptativo (grid 2x2 para opções curtas, lista para longas)
- Implementada navegação direta para Home usando NavigationPath
- Corrigidos erros de compilação (switch exaustivo, actor isolation)"

echo "📤 Fazendo push para o GitHub..."
git push origin main

echo "✅ Commit e push concluídos!"
