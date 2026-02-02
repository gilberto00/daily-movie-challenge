# ⏰ Como Configurar e Usar o Cloud Scheduler

Este guia explica como acessar o Cloud Scheduler para disparar manualmente as funções agendadas de notificação.

---

## 📋 Visão Geral

Quando você faz deploy das Cloud Functions com `functions.pubsub.schedule()`, o **Firebase cria automaticamente** os jobs no Cloud Scheduler. Você **não precisa criar** nada manualmente — apenas acessar e usar "Run now" para testar.

---

## 🔧 Passo a Passo: Acessar o Cloud Scheduler

### 1. Abrir o Google Cloud Console

1. Acesse: [https://console.cloud.google.com/cloudscheduler](https://console.cloud.google.com/cloudscheduler)
2. **Importante:** use o projeto correto.

### 2. Selecionar o Projeto Correto

1. No topo da página, clique no **seletor de projeto** (onde aparece o nome atual, ex: "My Project" ou outro ID).
2. Na lista, procure e selecione **`movie-daily-dev`** (o projeto do Firebase).
3. Se não aparecer, procure pelo nome do app ou pelo ID usado no Firebase Console.

> ⚠️ Se estiver em outro projeto (ex: `turing-terminus-107717`), os jobs **não aparecerão**. O projeto deve ser **movie-daily-dev**.

### 3. Verificar os Jobs

Após selecionar o projeto correto, você deve ver os jobs criados automaticamente pelo Firebase:

| Job | Função | Horário |
|-----|--------|---------|
| `firebase-schedule-sendDailyChallengeNotification-us-central1` | Notificação diária | 9h (America/Sao_Paulo) |
| `firebase-schedule-sendStreakReminderNotification-us-central1` | Lembrete de streak | 20h (America/Sao_Paulo) |

### 4. Executar Manualmente (Run Now)

1. Na tabela de jobs, encontre o job desejado.
2. Clique nos **três pontinhos (⋮)** na linha do job.
3. Selecione **"Run now"** / **"Executar agora"**.
4. O job será executado imediatamente e chamará a Cloud Function.

---

## 🔗 Link Direto para o Projeto

Para ir direto ao Cloud Scheduler do projeto **movie-daily-dev**:

**[https://console.cloud.google.com/cloudscheduler?project=movie-daily-dev](https://console.cloud.google.com/cloudscheduler?project=movie-daily-dev)**

---

## 📂 Se Não Encontrar o Projeto

1. Abra o **Firebase Console**: [https://console.firebase.google.com](https://console.firebase.google.com)
2. Selecione o projeto **movie-daily-dev**.
3. Clique no ícone de **engrenagem** → **Project settings**.
4. Na seção **"Your apps"** ou **"General"**, confira o **Project ID**.
5. Use esse ID na URL do Cloud Scheduler: `?project=SEU_PROJECT_ID`

---

## 🐛 Problemas Comuns

### "No Cloud Scheduler jobs to display"

- **Causa:** Projeto errado selecionado.
- **Solução:** Troque para o projeto **movie-daily-dev** no seletor de projetos.

### "Job não aparece"

- **Causa:** As Cloud Functions podem não ter sido deployadas ou houve erro no deploy.
- **Solução:** Rode novamente:
  ```bash
  cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
  npx firebase-tools deploy --only functions
  ```

### "Run now não faz nada"

- Verifique os **logs** da função no Firebase Console:
  - **Functions** → selecione `sendDailyChallengeNotification` → **Logs**
- Ou via terminal:
  ```bash
  npx firebase-tools functions:log
  ```

---

## 📅 Configuração Atual das Funções

As funções estão configuradas no código (`functions/src/index.ts`):

| Função | Cron | Horário (São Paulo) |
|--------|------|----------------------|
| `sendDailyChallengeNotification` | `0 9 * * *` | 9h da manhã |
| `sendStreakReminderNotification` | `0 20 * * *` | 20h da noite |

Para alterar o horário, edite o código e faça um novo deploy das functions.
