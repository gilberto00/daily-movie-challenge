# 🧪 Como Testar Push Notifications em Dispositivo Físico

## 📋 Pré-requisitos

- ✅ APNs configurado no Firebase Console
- ✅ Cloud Functions deployadas
- ✅ Regras do Firestore deployadas
- ✅ Dispositivo iOS físico conectado
- ✅ Xcode instalado e configurado

---

## 🔧 PARTE 1: Preparar o Dispositivo

### 1.1 Conectar o Dispositivo

1. **Conecte seu iPhone/iPad via USB ao Mac**
2. **Desbloqueie o dispositivo** e confie no computador se solicitado
3. **No Xcode:**
   - Abra o projeto `DailyMovieChallenge.xcodeproj`
   - No seletor de dispositivos (barra superior), selecione seu dispositivo físico
   - Se não aparecer, vá em **Window → Devices and Simulators** e verifique a conexão

### 1.2 Configurar Signing

1. **No Xcode:**
   - Selecione o projeto no Navigator
   - Selecione o target **DailyMovieChallenge**
   - Vá na aba **Signing & Capabilities**
   - Marque **Automatically manage signing**
   - Selecione seu **Team** (Apple Developer)
   - Verifique se o **Bundle Identifier** está correto: `com.gilbertorosa.cinedaily.DailyMovieChallenge`

2. **Se houver erros de signing:**
   - Clique em **Download Manual Profiles**
   - Ou ajuste o Bundle ID se necessário

---

## 🚀 PARTE 2: Executar o App

### 2.1 Build e Run

1. **No Xcode:**
   - Pressione **⌘R** (ou clique em Run)
   - Aguarde o build e instalação no dispositivo

2. **No dispositivo:**
   - O app será instalado e aberto automaticamente
   - Se aparecer um aviso de "Untrusted Developer":
     - Vá em **Settings → General → VPN & Device Management**
     - Toque no seu perfil de desenvolvedor
     - Toque em **Trust**

### 2.2 Conceder Permissões

1. **Quando o app abrir:**
   - Um popup aparecerá: **"CineDaily" Would Like to Send You Notifications**
   - Toque em **Allow** (Permitir)

2. **Verificar permissões:**
   - Vá em **Settings → Notifications → CineDaily**
   - Verifique se está habilitado
   - Configure como preferir (Banners, Sounds, etc.)

---

## ✅ PARTE 3: Verificar Token FCM

### 3.1 Verificar no Console do Xcode

1. **No Xcode:**
   - Abra o **Console** (View → Debug Area → Activate Console ou ⇧⌘C)
   - Procure por mensagens como:
     ```
     ✅ [NotificationService] FCM token saved to Firestore
     ✅ [NotificationService] FCM token: [TOKEN_AQUI]
     ```

2. **Se não aparecer:**
   - Verifique se o usuário está autenticado
   - Verifique se há erros no console
   - Aguarde alguns segundos (o token pode demorar para ser gerado)

### 3.2 Verificar no Firestore

1. **Acesse o Firebase Console:**
   - URL: https://console.firebase.google.com
   - Selecione o projeto **movie-daily-dev**
   - Vá em **Firestore Database**

2. **Verificar a collection `fcmTokens`:**
   - Procure pela collection `fcmTokens`
   - Deve haver um documento com o ID do usuário (ex: `[userId]`)
   - O documento deve conter:
     ```json
     {
       "token": "FCM_TOKEN_AQUI",
       "updatedAt": timestamp,
       "platform": "iOS"
     }
     ```

3. **Se não aparecer:**
   - Verifique se o usuário está autenticado no app
   - Verifique as regras do Firestore
   - Verifique os logs do console do Xcode

---

## 🔔 PARTE 4: Enviar Notificação de Teste

### 4.1 Via Firebase Console (Método Mais Fácil)

1. **Acesse o Firebase Console:**
   - URL: https://console.firebase.google.com
   - Selecione o projeto **movie-daily-dev**
   - Vá em **Cloud Messaging** (no menu lateral)

2. **Enviar mensagem de teste:**
   - Clique em **Send test message**
   - No campo **FCM registration token**, cole o token que você viu:
     - No console do Xcode, ou
     - No Firestore (`fcmTokens/{userId}/token`)
   - **Notification title:** `Teste de Notificação`
   - **Notification text:** `Esta é uma notificação de teste! 🎬`
   - Clique em **Test**

3. **Verificar recebimento:**
   - A notificação deve aparecer no dispositivo em alguns segundos
   - Se o app estiver em foreground, a notificação pode aparecer de forma diferente
   - Se o app estiver em background ou fechado, a notificação aparecerá normalmente

### 4.2 Via Cloud Function (Teste Programático)

Você pode criar uma função de teste temporária ou usar o Firebase CLI:

```bash
# Testar notificação diária manualmente
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge/functions
npx firebase-tools functions:call sendDailyChallengeNotification
```

---

## 🧪 PARTE 5: Testar Deep Linking

### 5.1 Testar Deep Link a partir de Notificação

1. **Enviar notificação com payload de deep link:**
   - No Firebase Console → Cloud Messaging → Send test message
   - Cole o FCM token
   - Em **Additional options**, adicione:
     - **Key:** `destination`
     - **Value:** `home` (ou `leaderboard`, `settings`, `trivia`)

2. **Verificar comportamento:**
   - Toque na notificação
   - O app deve abrir e navegar para o destino especificado

### 5.2 Testar Deep Link via URL Scheme

1. **No Mac (Terminal):**
   ```bash
   # Abrir Home
   xcrun simctl openurl booted "dailymoviechallenge://home"
   
   # Abrir Settings
   xcrun simctl openurl booted "dailymoviechallenge://settings"
   
   # Abrir Leaderboard
   xcrun simctl openurl booted "dailymoviechallenge://leaderboard"
   ```

2. **No Safari (Dispositivo Físico):**
   - Abra o Safari no dispositivo
   - Digite na barra de endereços: `dailymoviechallenge://home`
   - O app deve abrir automaticamente

---

## 📊 PARTE 6: Verificar Logs e Debugging

### 6.1 Logs do Xcode

1. **Console do Xcode:**
   - Procure por mensagens com prefixos:
     - `✅ [NotificationService]` - Sucesso
     - `⚠️ [NotificationService]` - Avisos
     - `❌ [NotificationService]` - Erros
     - `🔗 [DeepLinkService]` - Deep links
     - `🔄 [DailyMovieChallengeApp]` - App lifecycle

2. **Filtrar logs:**
   - No console, digite: `NotificationService` ou `FCM` para filtrar

### 6.2 Logs das Cloud Functions

1. **Via Firebase CLI:**
   ```bash
   cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
   npx firebase-tools functions:log
   ```

2. **Via Firebase Console:**
   - Vá em **Functions** → Selecione a função → **Logs**

### 6.3 Verificar Status do APNs

1. **No Firebase Console:**
   - Vá em **Project Settings → Cloud Messaging**
   - Verifique se o APNs está configurado:
     - ✅ Development: Configurado
     - ✅ Production: Configurado

---

## ✅ Checklist de Testes

### Testes Básicos
- [ ] App instala e abre no dispositivo físico
- [ ] Permissão de notificações é solicitada e concedida
- [ ] Token FCM é gerado e salvo no Firestore
- [ ] Notificação de teste é recebida
- [ ] Notificação aparece quando app está em background
- [ ] Notificação aparece quando app está fechado

### Testes de Deep Linking
- [ ] Deep link via URL scheme funciona (`dailymoviechallenge://home`)
- [ ] Deep link a partir de notificação funciona
- [ ] App navega corretamente para o destino especificado

### Testes de Funcionalidades
- [ ] Notificação abre o app ao ser tocada
- [ ] Deep linking funciona corretamente
- [ ] Configurações de notificações podem ser alteradas
- [ ] Token FCM é atualizado automaticamente

---

## 🐛 Troubleshooting

### "Token FCM não está sendo salvo"

**Verificar:**
1. Usuário está autenticado? (verifique no console do Xcode)
2. Regras do Firestore permitem escrita? (verifique em Firestore → Rules)
3. Há erros no console do Xcode?
4. APNs está configurado no Firebase?

**Solução:**
- Verifique os logs do console do Xcode
- Verifique as regras do Firestore para `fcmTokens`
- Tente fazer logout e login novamente no app

### "Notificações não chegam"

**Verificar:**
1. Permissão foi concedida? (Settings → Notifications → CineDaily)
2. Token FCM está salvo no Firestore?
3. APNs está configurado no Firebase?
4. App está em background ou fechado? (notificações podem não aparecer em foreground)

**Solução:**
- Feche o app completamente (swipe up no app switcher)
- Envie uma notificação de teste novamente
- Verifique os logs das Cloud Functions
- Verifique se o dispositivo está conectado à internet

### "Deep linking não funciona"

**Verificar:**
1. URL scheme está correto? (`dailymoviechallenge://`)
2. App está instalado no dispositivo?
3. Há erros no console do Xcode?

**Solução:**
- Verifique o `Info.plist` se contém `CFBundleURLTypes`
- Tente reiniciar o app
- Verifique os logs do `DeepLinkService` no console

### "Cloud Functions não executam"

**Verificar:**
1. Functions foram deployadas? (`npx firebase-tools functions:list`)
2. Cloud Scheduler está habilitado?
3. Há erros nos logs das functions?

**Solução:**
- Verifique os logs: `npx firebase-tools functions:log`
- Verifique se o timezone está correto (America/Sao_Paulo)
- Tente executar a function manualmente

---

## 📝 Comandos Úteis

### Verificar Functions Deployadas
```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
npx firebase-tools functions:list
```

### Ver Logs das Functions
```bash
npx firebase-tools functions:log
```

### Testar Function Manualmente
```bash
npx firebase-tools functions:call sendDailyChallengeNotification
```

### Verificar Regras do Firestore
```bash
npx firebase-tools firestore:rules:get
```

---

## 🎯 Próximos Passos Após Testes

1. **Testar notificações agendadas:**
   - Aguardar o horário agendado (9h para daily challenge, 20h para streak reminder)
   - Ou ajustar temporariamente o horário nas Cloud Functions para testar

2. **Testar notificações de badges:**
   - Complete desafios para ganhar badges
   - Verifique se a notificação é enviada

3. **Monitorar uso:**
   - Verifique quantos tokens FCM estão ativos no Firestore
   - Monitore os logs das Cloud Functions

---

**Status:** ✅ Pronto para testar!  
**Tempo estimado:** 15-30 minutos para testes completos
