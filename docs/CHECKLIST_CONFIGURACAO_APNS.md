# ✅ Checklist: Configuração de APNs para Push Notifications

## 📋 Pré-requisitos
- ✅ Apple Developer Membership ativo
- ✅ Credenciais do Apple Developer Portal
- ✅ Projeto Firebase configurado
- ✅ App iOS com Bundle ID definido

---

## 🔐 PARTE 1: Apple Developer Portal

### 1.1 Criar APNs Auth Key (.p8) - RECOMENDADO

1. **Acesse o Apple Developer Portal:**
   - URL: https://developer.apple.com/account/resources/authkeys/list
   - Faça login com sua conta Apple Developer

2. **Criar nova Auth Key:**
   - Clique no botão **+** (criar nova key)
   - Preencha:
     - **Key Name:** `DailyMovieChallenge APNs Key` (ou qualquer nome descritivo)
     - **Enable:** ✅ **Apple Push Notifications service (APNs)**
   - Clique em **Continue**
   - Revise e clique em **Register**

3. **Download da Key:**
   - ⚠️ **IMPORTANTE:** Você só pode baixar a key UMA VEZ!
   - Clique em **Download**
   - O arquivo será baixado como `AuthKey_XXXXXXXXXX.p8`
   - **Guarde este arquivo em local seguro!** (você não poderá baixá-lo novamente)

4. **Anotar informações:**
   - Anote o **Key ID** (ex: `ABC123XYZ`) - você verá na página da key
   - Anote o **Team ID** (ex: `XYZ123ABC`) - você verá no canto superior direito do portal
   - Guarde o arquivo `.p8` em local seguro

### 1.2 Verificar/Criar App ID (se necessário)

1. **Acesse:**
   - URL: https://developer.apple.com/account/resources/identifiers/list

2. **Verificar se seu App ID existe:**
   - Procure pelo Bundle ID do seu app: `com.gilbertorosa.cinedaily.DailyMovieChallenge`
   - Se não existir, crie um novo:
     - Clique em **+**
     - Selecione **App IDs** → **Continue**
     - Selecione **App**
     - Preencha:
       - **Description:** `Daily Movie Challenge`
       - **Bundle ID:** `com.gilbertorosa.cinedaily.DailyMovieChallenge` (ou use Explicit)
     - Marque **Push Notifications** em Capabilities
     - Clique em **Continue** → **Register**

3. **Habilitar Push Notifications no App ID:**
   - Se já existe, clique no App ID
   - Verifique se **Push Notifications** está marcado
   - Se não estiver, edite e marque

---

## 🔥 PARTE 2: Firebase Console

### 2.1 Configurar APNs no Firebase

1. **Acesse o Firebase Console:**
   - URL: https://console.firebase.google.com
   - Selecione o projeto: `movie-daily-dev` (ou seu projeto)

2. **Navegar para Cloud Messaging:**
   - Clique no ícone de **engrenagem** (⚙️) → **Project Settings**
   - Vá na aba **Cloud Messaging**

3. **Upload do APNs Auth Key (.p8):**
   - Na seção **Apple app configuration**
   - Clique em **Upload** (ou **Add** se já houver algo)
   - Selecione **APNs Auth Key**
   - Faça upload do arquivo `.p8` que você baixou
   - Cole o **Key ID** que você anotou
   - Clique em **Upload**

4. **Verificar configuração:**
   - Você deve ver:
     - ✅ Status: "Active" ou "Configurado"
     - ✅ Data de upload
     - ✅ Key ID exibido

### 2.2 Verificar App iOS no Firebase

1. **Na mesma página (Project Settings):**
   - Vá na aba **General**
   - Verifique se seu app iOS está listado
   - Se não estiver, adicione:
     - Clique em **Add app** → **iOS**
     - Bundle ID: `com.gilbertorosa.cinedaily.DailyMovieChallenge`
     - Baixe o `GoogleService-Info.plist` novamente se necessário

---

## 📱 PARTE 3: Xcode

### 3.1 Verificar Firebase Messaging SDK

1. **Abrir o projeto no Xcode:**
   - Abra `DailyMovieChallenge.xcodeproj`

2. **Resolver Package Dependencies:**
   - Vá em **File → Packages → Resolve Package Versions**
   - Aguarde a resolução
   - Verifique se `FirebaseMessaging` aparece nas dependências

3. **Se FirebaseMessaging não estiver presente:**
   - Vá em **File → Add Package Dependencies...**
   - Cole a URL: `https://github.com/firebase/firebase-ios-sdk`
   - Selecione a versão mais recente
   - **Marque apenas:** `FirebaseMessaging`
   - Clique em **Add Package**

### 3.2 Configurar Capabilities

1. **Selecionar o Target:**
   - No Project Navigator, selecione o projeto
   - Selecione o target **DailyMovieChallenge**

2. **Adicionar Push Notifications:**
   - Vá na aba **Signing & Capabilities**
   - Clique em **+ Capability**
   - Procure e adicione **Push Notifications**
   - ✅ Deve aparecer na lista de capabilities

3. **Adicionar Background Modes:**
   - Clique em **+ Capability** novamente
   - Procure e adicione **Background Modes**
   - Marque a opção:
     - ✅ **Remote notifications**

### 3.3 Verificar Signing & Capabilities

1. **Verificar Automatic Signing:**
   - Na aba **Signing & Capabilities**
   - Verifique se **Automatically manage signing** está marcado
   - Selecione seu **Team** (Apple Developer)
   - Verifique se o **Bundle Identifier** está correto

2. **Verificar Provisioning Profile:**
   - O Xcode deve criar automaticamente um Provisioning Profile
   - Se houver erros, clique em **Download Manual Profiles**

---

## 🚀 PARTE 4: Deploy das Cloud Functions e Regras

### 4.1 Deploy das Regras do Firestore

```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
npx firebase-tools deploy --only firestore:rules
```

### 4.2 Deploy das Cloud Functions

```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge/functions
npm install
cd ..
npx firebase-tools deploy --only functions
```

**Ou use o script automatizado:**
```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
chmod +x deploy_push_notifications.sh
./deploy_push_notifications.sh
```

---

## 🧪 PARTE 5: Testar

### 5.1 Testar no Dispositivo Físico

1. **Conectar dispositivo iOS:**
   - Conecte seu iPhone/iPad via USB
   - No Xcode, selecione o dispositivo como destino

2. **Executar o app:**
   - Build e Run (⌘R)
   - Aceite a permissão de notificações quando solicitado

3. **Verificar token FCM:**
   - Abra o console do Xcode
   - Procure por: `✅ [NotificationService] FCM token saved to Firestore`
   - Verifique no Firestore se o token foi salvo em `fcmTokens/{userId}`

### 5.2 Testar Notificação Manualmente

1. **Via Firebase Console:**
   - Vá em **Cloud Messaging** → **Send test message**
   - Cole o FCM token do seu dispositivo
   - Digite uma mensagem de teste
   - Clique em **Test**

2. **Verificar recebimento:**
   - A notificação deve aparecer no dispositivo
   - Ao tocar, o app deve abrir

---

## ✅ Checklist Final

### Apple Developer Portal
- [ ] Auth Key (.p8) criada e baixada
- [ ] Key ID anotado
- [ ] Team ID anotado
- [ ] App ID verificado/criado
- [ ] Push Notifications habilitado no App ID

### Firebase Console
- [ ] APNs Auth Key (.p8) feito upload
- [ ] Key ID configurado corretamente
- [ ] Status mostra "Active" ou "Configurado"
- [ ] App iOS verificado/adicionado

### Xcode
- [ ] FirebaseMessaging SDK adicionado via SPM
- [ ] Push Notifications capability adicionada
- [ ] Background Modes capability adicionada
- [ ] Remote notifications marcado
- [ ] Signing configurado corretamente
- [ ] Bundle ID correto

### Deploy
- [ ] Regras do Firestore deployadas
- [ ] Cloud Functions deployadas
- [ ] Sem erros no deploy

### Testes
- [ ] App executado no dispositivo físico
- [ ] Permissão de notificações concedida
- [ ] Token FCM salvo no Firestore
- [ ] Notificação de teste recebida
- [ ] Deep linking funcionando (app abre ao tocar notificação)

---

## 🐛 Troubleshooting

### "Não consigo criar Auth Key"
- Verifique se sua conta Apple Developer está ativa
- Verifique se você tem permissões de Admin ou Account Holder
- Tente em outro navegador

### "Firebase não aceita o arquivo .p8"
- Verifique se o arquivo não está corrompido
- Verifique se o Key ID está correto (sem espaços extras)
- Tente fazer upload novamente

### "Token FCM não está sendo salvo"
- Verifique se o usuário está autenticado
- Verifique os logs do Xcode
- Verifique as regras do Firestore
- Verifique se o APNs está configurado no Firebase

### "Notificações não chegam"
- ⚠️ **Simulador não recebe push notifications** - use dispositivo físico
- Verifique se o APNs está configurado no Firebase
- Verifique se as capabilities estão configuradas no Xcode
- Verifique se o token FCM está salvo no Firestore
- Verifique os logs das Cloud Functions

### "Cloud Functions não executam"
- Verifique se o Cloud Scheduler está habilitado
- Verifique os logs: `npx firebase-tools functions:log`
- Verifique se o timezone está correto (America/Sao_Paulo)

---

## 📝 Informações Importantes

- **Arquivo .p8:** Guarde em local seguro - você não pode baixá-lo novamente
- **Key ID:** Anote e guarde - você precisará dele se recriar a configuração
- **Team ID:** Pode ser útil para troubleshooting
- **Dispositivo Físico:** Simulador iOS não recebe push notifications
- **Horários:** Notificações agendadas usam horário de São Paulo (America/Sao_Paulo)

---

**Data de Criação:** 25 de Janeiro de 2026  
**Status:** ✅ Pronto para configuração
