# 🚀 Como Testar Push Notifications via TestFlight

## ✅ Vantagens do TestFlight

- ✅ **Não precisa conectar via USB** - Teste em qualquer dispositivo
- ✅ **Teste em múltiplos dispositivos** - Adicione testadores
- ✅ **Mais próximo da experiência real** - Build de produção
- ✅ **Teste remoto** - Testadores podem estar em qualquer lugar
- ✅ **Distribuição fácil** - Compartilhe o link de convite

---

## 📋 Pré-requisitos

- ✅ Apple Developer Membership ativo
- ✅ APNs configurado no Firebase Console
- ✅ App configurado no App Store Connect
- ✅ Cloud Functions deployadas
- ✅ Regras do Firestore deployadas

---

## 🔧 PARTE 1: Configurar App no App Store Connect

### 1.1 Criar App no App Store Connect

1. **Acesse o App Store Connect:**
   - URL: https://appstoreconnect.apple.com
   - Faça login com sua conta Apple Developer

2. **Criar novo app:**
   - Clique em **My Apps** → **+** (criar novo app)
   - Preencha:
     - **Platform:** iOS
     - **Name:** `CineDaily` (ou o nome que preferir)
     - **Primary Language:** Português (ou sua preferência)
     - **Bundle ID:** Selecione `com.gilbertorosa.cinedaily.DailyMovieChallenge`
     - **SKU:** `cinedaily-ios` (qualquer identificador único)
   - Clique em **Create**

### 1.2 Configurar Informações Básicas

1. **Na página do app:**
   - Preencha informações básicas (pode ser mínimo para testes)
   - **Privacy Policy URL:** (opcional para testes internos)
   - Salve as alterações

---

## 📱 PARTE 2: Preparar Build para TestFlight

### 2.1 Configurar Xcode para Archive

1. **No Xcode:**
   - Selecione o target **DailyMovieChallenge**
   - Vá em **Signing & Capabilities**
   - Verifique:
     - ✅ **Automatically manage signing** está marcado
     - ✅ **Team** está selecionado (seu Apple Developer Team)
     - ✅ **Bundle Identifier** está correto

2. **Selecionar dispositivo genérico:**
   - No seletor de dispositivos (barra superior), selecione **Any iOS Device** (ou **Generic iOS Device**)

### 2.2 Criar Archive

1. **No Xcode:**
   - Vá em **Product → Archive**
   - Aguarde o build e archive (pode demorar alguns minutos)

2. **Organizer abrirá automaticamente:**
   - Você verá o archive criado
   - Se não abrir, vá em **Window → Organizer**

### 2.3 Validar e Distribuir

1. **No Organizer:**
   - Selecione o archive mais recente
   - Clique em **Distribute App**

2. **Escolher método de distribuição:**
   - Selecione **App Store Connect**
   - Clique em **Next**

3. **Opções de distribuição:**
   - Selecione **Upload**
   - Clique em **Next**

4. **Opções de distribuição (avançado):**
   - Deixe as opções padrão
   - Clique em **Next**

5. **Revisar:**
   - Revise as informações
   - Clique em **Upload**

6. **Aguardar upload:**
   - O upload pode demorar alguns minutos
   - Você verá o progresso na barra

---

## 🧪 PARTE 3: Configurar TestFlight

### 3.1 Adicionar Build ao TestFlight

1. **No App Store Connect:**
   - Vá em **My Apps** → Selecione seu app **CineDaily**
   - Vá na aba **TestFlight**

2. **Aguardar processamento:**
   - O build aparecerá em "Processing" (pode levar 10-30 minutos)
   - Quando estiver pronto, aparecerá em "Ready to Submit" ou "Ready to Test"

3. **Se houver problemas:**
   - Verifique o email associado à sua conta
   - Verifique se há avisos ou erros na página do build

### 3.2 Adicionar Testadores Internos

1. **No TestFlight:**
   - Vá em **Internal Testing**
   - Clique em **+** para adicionar grupo (se não existir)
   - Nome do grupo: `Internal Testers`

2. **Adicionar você mesmo:**
   - Clique em **Add Testers**
   - Selecione sua conta Apple ID
   - Clique em **Add**

3. **Selecionar build:**
   - Selecione o build que você acabou de fazer upload
   - Clique em **Start Testing**

### 3.3 Instalar TestFlight App

1. **No seu iPhone/iPad:**
   - Abra a App Store
   - Procure por **TestFlight**
   - Instale o app TestFlight (é gratuito)

2. **Aceitar convite:**
   - Você receberá um email de convite (ou pode acessar diretamente)
   - Abra o email no dispositivo
   - Toque no link de convite
   - O TestFlight abrirá automaticamente

---

## 📲 PARTE 4: Instalar e Testar

### 4.1 Instalar App via TestFlight

1. **No TestFlight (no dispositivo):**
   - Você verá o app **CineDaily** disponível
   - Toque em **Install**
   - Aguarde a instalação

2. **Primeira execução:**
   - O app será instalado e você pode abri-lo
   - **Importante:** TestFlight apps têm um banner amarelo no topo

### 4.2 Testar Push Notifications

1. **Abrir o app:**
   - Toque no app para abrir
   - Aceite a permissão de notificações quando solicitado

2. **Verificar token FCM:**
   - Como você não tem acesso ao console do Xcode, verifique no Firestore:
     - Firebase Console → Firestore Database
     - Collection `fcmTokens`
     - Procure pelo documento com seu `userId`
     - O token deve estar lá

3. **Enviar notificação de teste:**
   - Firebase Console → Cloud Messaging → Send test message
   - Cole o token FCM do Firestore
   - Envie a notificação

4. **Verificar recebimento:**
   - Feche o app completamente
   - A notificação deve aparecer
   - Toque na notificação para abrir o app

---

## 👥 PARTE 5: Adicionar Testadores Externos (Opcional)

### 5.1 Configurar Teste Externo

1. **No App Store Connect:**
   - Vá em **TestFlight → External Testing**
   - Clique em **+** para criar grupo
   - Nome: `Beta Testers`

2. **Adicionar build:**
   - Selecione o build
   - Clique em **Next**

3. **Informações de teste:**
   - Preencha informações básicas (pode ser mínimo)
   - Clique em **Next**

4. **Revisar e enviar:**
   - Revise as informações
   - Clique em **Submit for Review**
   - **Nota:** Pode levar algumas horas para aprovação

5. **Compartilhar link:**
   - Após aprovação, você receberá um link público
   - Compartilhe com testadores
   - Eles precisam instalar o TestFlight app primeiro

---

## ✅ Checklist TestFlight

### Preparação
- [ ] App criado no App Store Connect
- [ ] Bundle ID configurado corretamente
- [ ] Archive criado no Xcode
- [ ] Build validado e enviado
- [ ] Build processado no App Store Connect

### TestFlight
- [ ] TestFlight app instalado no dispositivo
- [ ] App instalado via TestFlight
- [ ] Permissão de notificações concedida
- [ ] Token FCM verificado no Firestore
- [ ] Notificação de teste enviada e recebida

### Testes
- [ ] Notificação recebida quando app está em background
- [ ] Notificação recebida quando app está fechado
- [ ] Deep linking funciona ao tocar na notificação
- [ ] App abre corretamente

---

## 🐛 Troubleshooting TestFlight

### "Build não aparece no TestFlight"

**Verificar:**
1. Build foi processado? (pode levar 10-30 minutos)
2. Há erros ou avisos na página do build?
3. Build foi aprovado para teste?

**Solução:**
- Aguarde o processamento
- Verifique o email associado à conta
- Verifique se há problemas de certificado ou provisioning profile

### "Não recebo convite de teste"

**Verificar:**
1. Email está correto no App Store Connect?
2. Email está na caixa de spam?
3. Você está no grupo de testadores internos?

**Solução:**
- Verifique a aba **Users and Access** no App Store Connect
- Adicione-se manualmente como testador interno
- Use o link direto: `https://testflight.apple.com/join/[CODE]`

### "App não instala via TestFlight"

**Verificar:**
1. TestFlight app está instalado?
2. Você aceitou o convite?
3. Build está disponível para teste?

**Solução:**
- Instale o TestFlight app primeiro
- Aceite o convite novamente
- Verifique se o build está "Ready to Test"

### "Push notifications não funcionam no TestFlight"

**Verificar:**
1. APNs está configurado no Firebase?
2. Permissão foi concedida no app?
3. Token FCM está salvo no Firestore?

**Solução:**
- TestFlight usa o mesmo APNs que produção
- Verifique se o APNs Production está configurado no Firebase
- Verifique os logs no Firestore
- Teste enviando notificação manualmente

---

## 📝 Diferenças: TestFlight vs Build Local

### TestFlight (Recomendado para Testes)
- ✅ Build de produção (mais próximo do real)
- ✅ Não precisa conectar via USB
- ✅ Pode testar em múltiplos dispositivos
- ✅ Testadores externos podem testar
- ⚠️ Precisa esperar processamento (10-30 min)
- ⚠️ Precisa criar app no App Store Connect

### Build Local (Xcode)
- ✅ Mais rápido (sem esperar processamento)
- ✅ Acesso direto aos logs do console
- ✅ Debug mais fácil
- ⚠️ Precisa conectar via USB
- ⚠️ Apenas um dispositivo por vez

---

## 🎯 Recomendação

**Para testes iniciais:** Use build local (Xcode) para debug rápido  
**Para testes finais:** Use TestFlight para validar em condições reais

**Ambos funcionam perfeitamente para testar push notifications!**

---

## 📚 Recursos Úteis

- **App Store Connect:** https://appstoreconnect.apple.com
- **TestFlight Documentation:** https://developer.apple.com/testflight/
- **Firebase Console:** https://console.firebase.google.com

---

**Status:** ✅ Pronto para usar TestFlight!  
**Tempo estimado para setup inicial:** 30-60 minutos (incluindo processamento)
