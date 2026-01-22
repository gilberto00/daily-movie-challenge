# 📱 SPRINT 2 - Item 7: Notificações Push - Implementação

## 📋 Objetivo
Implementar sistema completo de notificações push para aumentar retenção e engajamento dos usuários.

---

## ✅ Checklist de Implementação

### Fase 1: Setup Firebase Cloud Messaging (FCM) no iOS
- [ ] Adicionar Firebase Messaging SDK via SPM
- [ ] Configurar FCM no `DailyMovieChallengeApp.swift`
- [ ] Solicitar permissão de notificações
- [ ] Implementar registro de FCM tokens
- [ ] Salvar tokens no Firestore (`fcmTokens/{userId}`)

### Fase 2: Cloud Functions para Notificações
- [ ] Adicionar `firebase-admin` FCM SDK nas dependências
- [ ] Implementar scheduled function para notificação diária (9h)
- [ ] Implementar trigger function para streak em risco (20h)
- [ ] Implementar trigger function para badges/conquistas
- [ ] Configurar Cloud Scheduler

### Fase 3: Deep Linking
- [ ] Configurar URL schemes no Info.plist
- [ ] Implementar handling de notificações
- [ ] Roteamento interno baseado no tipo de notificação

### Fase 4: Configurações Básicas (Opcional)
- [ ] Tela simples de Settings para notificações
- [ ] Permitir desabilitar tipos específicos

---

## 🔧 Estrutura de Dados Firestore

### fcmTokens/{userId}
```javascript
{
  token: string,
  updatedAt: timestamp,
  deviceInfo?: {
    platform: "iOS",
    version: string
  }
}
```

### notificationSettings/{userId}
```javascript
{
  dailyChallenge: boolean (default: true),
  streakReminder: boolean (default: true),
  achievements: boolean (default: true),
  comments: boolean (default: false)
}
```

---

## 📝 Tipos de Notificações

### 1. Notificação Diária (9h)
- **Quando:** Diariamente às 9h
- **Conteúdo:** "Novo desafio disponível! Teste seus conhecimentos sobre filmes 🎬"
- **Ação:** Abre HomeView

### 2. Streak em Risco (20h)
- **Quando:** Se usuário tem streak > 0 e não completou desafio do dia
- **Conteúdo:** "Não perca sua streak de X dias! Complete o desafio de hoje 🔥"
- **Ação:** Abre HomeView

### 3. Conquista/Badge
- **Quando:** Usuário alcança nova conquista
- **Conteúdo:** "Parabéns! Você alcançou: [Nome do Badge] 🏆"
- **Ação:** Abre LeaderboardView ou HomeView

---

## 🚀 Próximos Passos

1. Adicionar Firebase Messaging SDK
2. Implementar registro de tokens
3. Criar Cloud Functions
4. Implementar deep linking
5. Testar notificações
