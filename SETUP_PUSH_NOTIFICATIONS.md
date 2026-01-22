# 📱 Setup Push Notifications - Item 7 Sprint 2

## ✅ O que já foi implementado

1. ✅ `NotificationService.swift` - Serviço para gerenciar notificações
2. ✅ `NotificationSettings` model - Configurações básicas
3. ✅ Funções no `FirestoreService` para tokens e settings
4. ✅ Cloud Functions para enviar notificações
5. ✅ Regras do Firestore atualizadas

---

## 🔧 Passos para Completar o Setup

### 1. Adicionar Firebase Messaging SDK no Xcode

1. Abra o projeto no Xcode
2. Vá em **File → Add Package Dependencies...**
3. Cole a URL: `https://github.com/firebase/firebase-ios-sdk`
4. Selecione a versão mais recente
5. **Marque apenas:** `FirebaseMessaging`
6. Clique em **Add Package**

### 2. Configurar Capabilities no Xcode

1. Selecione o target do projeto
2. Vá em **Signing & Capabilities**
3. Clique em **+ Capability**
4. Adicione **Push Notifications**
5. Adicione **Background Modes** e marque:
   - ✅ Remote notifications

### 3. Configurar APNs no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione o projeto `movie-daily-dev`
3. Vá em **Project Settings → Cloud Messaging**
4. Na seção **Apple app configuration**, faça upload do certificado APNs:
   - **Opção 1 (Recomendado):** APNs Auth Key (.p8)
     - Vá em [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
     - Crie uma nova key com "Apple Push Notifications service (APNs)"
     - Faça download e faça upload no Firebase
   - **Opção 2:** APNs Certificate (.p12)
     - Mais complexo, mas também funciona

### 4. Deploy das Cloud Functions

```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge/functions
npm install
cd ..
npx firebase-tools deploy --only functions
```

### 5. Deploy das Regras do Firestore

```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
npx firebase-tools deploy --only firestore:rules
```

### 6. Testar Notificações

1. Execute o app no simulador/dispositivo
2. Aceite a permissão de notificações quando solicitado
3. Verifique no console do Xcode se o token FCM foi salvo
4. Verifique no Firestore se o token foi salvo em `fcmTokens/{userId}`

---

## 📋 Estrutura de Dados Firestore

### fcmTokens/{userId}
```javascript
{
  token: "FCM_TOKEN_AQUI",
  updatedAt: timestamp,
  platform: "iOS"
}
```

### notificationSettings/{userId}
```javascript
{
  dailyChallenge: true,
  streakReminder: true,
  achievements: true,
  comments: false,
  updatedAt: timestamp
}
```

---

## 🔔 Tipos de Notificações

### 1. Notificação Diária (9h)
- **Quando:** Diariamente às 9h (horário de São Paulo)
- **Conteúdo:** "🎬 Novo Desafio Disponível! Teste seus conhecimentos sobre [filme] hoje!"
- **Ação:** Abre HomeView

### 2. Streak em Risco (20h)
- **Quando:** Se usuário tem streak > 0 e não completou desafio do dia
- **Conteúdo:** "🔥 Não Perca Sua Streak! Você tem uma streak de X dias!"
- **Ação:** Abre HomeView

### 3. Conquista/Badge
- **Quando:** Usuário alcança nova conquista
- **Conteúdo:** "🏆 Nova Conquista! Parabéns! Você alcançou: [Nome do Badge]"
- **Ação:** Abre LeaderboardView

---

## 🐛 Troubleshooting

### Token FCM não está sendo salvo
- Verifique se o usuário está autenticado
- Verifique os logs do console do Xcode
- Verifique as regras do Firestore

### Notificações não chegam
- Verifique se o APNs está configurado no Firebase
- Verifique se as capabilities estão configuradas no Xcode
- Verifique se o token FCM está salvo no Firestore
- Verifique os logs das Cloud Functions

### Cloud Functions não executam
- Verifique se o Cloud Scheduler está habilitado
- Verifique os logs: `npx firebase-tools functions:log`
- Verifique se o timezone está correto (America/Sao_Paulo)

---

## ✅ Checklist Final

- [ ] Firebase Messaging SDK adicionado via SPM
- [ ] Push Notifications capability adicionada
- [ ] Background Modes configurado
- [ ] APNs configurado no Firebase Console
- [ ] Cloud Functions deployadas
- [ ] Regras do Firestore deployadas
- [ ] Token FCM sendo salvo no Firestore
- [ ] Notificações sendo recebidas no app

---

## 🚀 Próximos Passos (Opcional)

1. **Deep Linking:** Implementar roteamento interno baseado no tipo de notificação
2. **Tela de Settings:** Permitir usuário configurar preferências de notificações
3. **Notificações de Comentários:** Implementar quando alguém responde comentário
