# 🚀 SPRINT 2 - Daily Movie Challenge

## 📋 Objetivo do Sprint
Melhorar a experiência social e competitiva do app, adicionando funcionalidades de interação e engajamento dos usuários.

---

## ✅ Itens do Sprint 2

### 5. Sistema de Comentários Completo
**Objetivo:** Expandir o sistema de comentários atual com funcionalidades avançadas.

**Funcionalidades a implementar:**
- ✅ Sistema básico de comentários (já implementado)
- [ ] Edição de comentários próprios
- [ ] Exclusão de comentários próprios
- [ ] Sistema de likes/reações em comentários
- [ ] Respostas/nested comments (opcional, depende da UX)
- [ ] Moderação básica (reportar comentários)
- [ ] Paginação/infinite scroll para comentários (se necessário)

**Benefícios:**
- Maior engajamento dos usuários
- Comunidade mais ativa
- Feedback sobre os desafios

---

### 6. Leaderboard
**Objetivo:** Criar sistema competitivo para motivar os usuários.

**Funcionalidades a implementar:**
- [ ] Tela de Leaderboard (classificação global)
- [ ] Cálculo de pontuação baseado em:
  - Streak atual
  - Total de desafios completados
  - Taxa de acerto (%)
  - Bonus por desafios extras completados
- [ ] Rankings:
  - Global (todos os tempos)
  - Semanal
  - Mensal
  - Por streak
- [ ] Badges/conquistas:
  - Streak de 7 dias
  - Streak de 30 dias
  - 100 desafios completados
  - Taxa de acerto > 80%
- [ ] Posição do usuário destacada
- [ ] Atualização em tempo real (Firestore listeners)

**Estrutura de dados Firestore:**
```javascript
users/{userId} {
  streak: number,
  totalChallenges: number,
  correctAnswers: number,
  totalAnswers: number,
  accuracyRate: number, // calculated: correctAnswers / totalAnswers
  score: number, // calculated based on streak, accuracy, etc.
  badges: string[],
  lastChallengeDate: timestamp,
  createdAt: timestamp
}

leaderboard/{period} {
  // period: "global" | "weekly" | "monthly"
  // Ou usar subcollections para organizar melhor
}
```

**Benefícios:**
- Gamificação
- Motivação para jogar diariamente
- Competição saudável

---

### 7. Notificações Push
**Objetivo:** Notificar os usuários sobre novos desafios e conquistas importantes.

**Plano detalhado:**

#### 7.1 Setup Firebase Cloud Messaging (FCM)
- [ ] Configurar FCM no projeto Firebase
- [ ] Adicionar Firebase Messaging SDK no iOS app
- [ ] Solicitar permissão de notificações ao usuário
- [ ] Implementar token registration/refresh

#### 7.2 Tipos de Notificações

**A. Notificação de Novo Desafio (Scheduled)**
- **Quando:** Diariamente, no horário configurado (ex: 9h da manhã)
- **Como:** Cloud Function com Cloud Scheduler (cron job)
- **Conteúdo:** 
  - "Novo desafio disponível! Teste seus conhecimentos sobre filmes 🎬"
  - Incluir título do filme (opcional)
- **Ação:** Ao tocar, abre o app diretamente no HomeView

**B. Notificação de Streak em Risco**
- **Quando:** Se o usuário não completou o desafio do dia e está próximo do fim do dia (ex: 20h)
- **Como:** Cloud Function verifica usuários com streak > 0 que não completaram o desafio do dia
- **Conteúdo:**
  - "Não perca sua streak! Complete o desafio de hoje 🔥"
  - Mostrar streak atual
- **Ação:** Ao tocar, abre o app no HomeView

**C. Notificação de Conquista/Badge**
- **Quando:** Usuário alcança uma nova conquista
- **Como:** Cloud Function detecta quando badge é adicionado ao usuário
- **Conteúdo:**
  - "Parabéns! Você alcançou: [Nome do Badge] 🏆"
  - Ex: "Streak de 7 dias!", "100 desafios completados!"
- **Ação:** Ao tocar, abre o app mostrando o badge/conquista

**D. Notificação de Resposta em Comentário (Futuro)**
- **Quando:** Alguém responde ao comentário do usuário
- **Como:** Cloud Function monitora novas respostas
- **Conteúdo:**
  - "[Nome] respondeu seu comentário"
  - Preview da resposta

**E. Notificação de Atualização no Leaderboard (Opcional)**
- **Quando:** Usuário sobe no ranking
- **Como:** Cloud Function compara posição atual com anterior
- **Conteúdo:**
  - "Você subiu para #X no ranking! 🎉"

#### 7.3 Implementação Técnica

**iOS App (Swift):**
```swift
// 1. Configurar FCM
import FirebaseMessaging
import UserNotifications

// 2. Solicitar permissão
UNUserNotificationCenter.current().requestAuthorization(...)

// 3. Registrar token
Messaging.messaging().token { token, error in
    // Salvar token no Firestore (collection: fcmTokens)
}

// 4. Handle notifications
// Foreground: Custom UI
// Background: Auto-handle
// User taps: Deep linking
```

**Cloud Functions (TypeScript):**
```typescript
// 1. Scheduled function para notificação diária
export const sendDailyChallengeNotification = functions
  .pubsub.schedule('0 9 * * *') // 9h todo dia
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    // Buscar todos os FCM tokens
    // Enviar notificação via FCM Admin SDK
  });

// 2. Trigger function para notificação de streak
// Dispara quando usuário tem streak > 0 e não completou desafio

// 3. Trigger function para badges
// Dispara quando novo badge é adicionado ao usuário
```

**Firestore Structure:**
```javascript
fcmTokens/{userId} {
  token: string,
  updatedAt: timestamp,
  deviceInfo?: object
}

notificationSettings/{userId} {
  dailyChallenge: boolean,
  streakReminder: boolean,
  achievements: boolean,
  comments: boolean
}
```

#### 7.4 Configurações do Usuário
- [ ] Tela de Settings para gerenciar notificações
- [ ] Permitir usuário desabilitar tipos específicos
- [ ] Preferência de horário para notificações diárias

#### 7.5 Deep Linking
- [ ] Configurar URL schemes (app://challenge, app://leaderboard)
- [ ] Handle notificações para abrir telas específicas
- [ ] Roteamento interno baseado no tipo de notificação

**Benefícios:**
- Retenção de usuários
- Aumento do engajamento diário
- Notificação oportuna de conquistas
- Melhor experiência do usuário

---

## 📊 Priorização

1. **Alta Prioridade (Implementação Imediata):**
   - Item 5: Sistema de Comentários completo - Edição/exclusão e likes
   - Item 6: Leaderboard - Gamificação essencial

2. **Média Prioridade (Após itens 5 e 6):**
   - Item 7: Notificações Push - Setup e notificação diária básica (7.1, 7.2.A)
   - Notificações de Streak e Badges (7.2.B, 7.2.C)

3. **Baixa Prioridade (Futuro):**
   - Configurações de notificações (7.4)
   - Notificações de comentários (7.2.D)
   - Notificações de leaderboard (7.2.E)

---

## 🔧 Dependências

### Para Item 5 (Comentários):
- ✅ Sistema básico de comentários já existe
- Firestore: Adicionar campos `likes`, `editedAt`, `parentCommentId` (se nested)
- Nova collection: `commentLikes/{commentId}/{userId}`

### Para Item 6 (Leaderboard):
- Firestore: Atualizar estrutura de `users` para incluir pontuação
- Nova collection: `leaderboard/{period}`
- Cloud Function: Calcular e atualizar rankings periodicamente
- Indexes no Firestore para queries ordenadas

### Para Item 7 (Push Notifications):
- Firebase Cloud Messaging configurado
- FCM tokens armazenados no Firestore
- Cloud Functions com FCM Admin SDK
- Cloud Scheduler para notificações agendadas
- Permissões de notificações no iOS

---

## 📅 Estimativa

- **Item 5 (Comentários):** ~3-4 dias
- **Item 6 (Leaderboard):** ~4-5 dias
- **Item 7 (Push Notifications):** ~3-4 dias
- **Total:** ~10-13 dias úteis

---

## ✅ Critérios de Aceite

### Item 5 - Comentários:
- [ ] Usuário pode editar seus próprios comentários
- [ ] Usuário pode excluir seus próprios comentários
- [ ] Usuário pode dar like em comentários
- [ ] Contador de likes é exibido e atualizado em tempo real
- [ ] Sistema de report está funcional

### Item 6 - Leaderboard:
- [ ] Leaderboard global exibido corretamente
- [ ] Cálculo de pontuação é preciso
- [ ] Rankings são atualizados em tempo real
- [ ] Posição do usuário está destacada
- [ ] Badges são concedidos corretamente

### Item 7 - Push Notifications:
- [ ] Notificações diárias são enviadas no horário correto
- [ ] Notificações de streak funcionam
- [ ] Notificações de badges funcionam
- [ ] Deep linking funciona corretamente
- [ ] Usuário pode configurar preferências

---

## 🚀 Próximos Passos

1. Priorizar e iniciar Item 6 (Leaderboard) - maior impacto
2. Implementar Item 5 (Comentários) em paralelo ou após
3. Configurar FCM e implementar Item 7 (Push Notifications)
