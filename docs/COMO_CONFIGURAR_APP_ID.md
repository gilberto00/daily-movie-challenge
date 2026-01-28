# 📱 Como Configurar App ID no Apple Developer Portal

## 📍 Onde você está agora

Você está na tela de registro do App ID no Apple Developer Portal:
- **Team ID:** 5453GZZ439
- **Bundle ID:** `com.gilbertorosa.cinedaily.DailyMovieChallenge` (Explicit)
- **Aba atual:** Capabilities

---

## ✅ PASSO 1: Preencher Informações Básicas

### 1.1 Description

1. **No campo "Description":**
   - Digite: `CineDaily iOS App` (ou qualquer nome descritivo)
   - ⚠️ **Não use caracteres especiais:** @, &, *, "

### 1.2 Bundle ID

1. **Verificar Bundle ID:**
   - Deve estar: `com.gilbertorosa.cinedaily.DailyMovieChallenge`
   - Tipo: **Explicit** (já selecionado) ✅

2. **Se precisar alterar:**
   - Certifique-se de que corresponde ao Bundle ID no Xcode
   - Formato recomendado: `com.domainname.appname`

---

## ✅ PASSO 2: Configurar Capabilities (IMPORTANTE!)

### 2.1 Capabilities Essenciais para Push Notifications

Na aba **"Capabilities"**, você precisa marcar:

#### ✅ OBRIGATÓRIO:
- ✅ **Push Notifications**
  - Procure na lista (pode usar Ctrl+F ou Cmd+F para buscar)
  - Marque a checkbox
  - Esta é a capability mais importante para push notifications!

#### ✅ RECOMENDADO (para funcionalidades do app):
- ✅ **Background Modes**
  - Necessário para receber notificações em background
  - Quando marcar, você verá opções adicionais
  - Marque: **Remote notifications**

#### ⚠️ OPCIONAL (depende das funcionalidades):
- ⚠️ **Associated Domains** (se for usar Universal Links no futuro)
- ⚠️ **App Groups** (se for compartilhar dados entre apps/extensions)

### 2.2 Como Marcar as Capabilities

1. **Na aba "Capabilities":**
   - Role a lista para baixo (ou use busca)
   - Procure por **"Push Notifications"**
   - Marque a checkbox ✅

2. **Se aparecerem opções adicionais:**
   - Para **Background Modes**, marque também:
     - ✅ **Remote notifications**

3. **Verificar:**
   - As capabilities marcadas devem aparecer com checkbox selecionado
   - Você pode desmarcar depois se necessário

---

## ✅ PASSO 3: Finalizar Registro

### 3.1 Revisar e Continuar

1. **Verificar informações:**
   - ✅ Description preenchida
   - ✅ Bundle ID correto
   - ✅ Push Notifications marcado
   - ✅ Background Modes marcado (se necessário)

2. **Clicar em "Continue":**
   - Revise as informações na tela de confirmação
   - Clique em **Register**

3. **Confirmação:**
   - Você verá uma mensagem de sucesso
   - O App ID será criado e aparecerá na lista de Identifiers

---

## 🔍 Onde Encontrar Push Notifications na Lista

A capability **Push Notifications** pode estar em diferentes lugares na lista. Procure por:

- **"Push Notifications"** (nome exato)
- Ou use a busca (Ctrl+F / Cmd+F) e digite: `push`

**Dica:** Geralmente está na seção de "App Services" ou perto do final da lista de capabilities.

---

## ✅ Checklist de Configuração

### Informações Básicas
- [ ] Description preenchida (sem caracteres especiais)
- [ ] Bundle ID correto: `com.gilbertorosa.cinedaily.DailyMovieChallenge`
- [ ] Tipo: Explicit (selecionado)

### Capabilities
- [ ] **Push Notifications** marcado ✅
- [ ] **Background Modes** marcado ✅
  - [ ] **Remote notifications** marcado (dentro de Background Modes)

### Finalização
- [ ] Informações revisadas
- [ ] App ID registrado com sucesso

---

## 🐛 Problemas Comuns

### "Não encontro Push Notifications na lista"

**Solução:**
- Use a busca (Ctrl+F / Cmd+F) e digite: `push`
- Role a lista completamente
- Verifique se está na aba "Capabilities" (não "App Services")

### "Push Notifications está desabilitado/cinza"

**Possíveis causas:**
- Sua conta Apple Developer pode ter limitações
- Algumas capabilities podem requerer configuração adicional

**Solução:**
- Verifique se sua conta Apple Developer está ativa
- Tente criar o App ID novamente
- Se persistir, verifique as permissões da sua conta

### "Bundle ID já existe"

**Solução:**
- Se você já criou este App ID antes, não precisa criar novamente
- Vá em "All Identifiers" e edite o existente
- Adicione as capabilities necessárias

---

## 📝 Próximos Passos Após Criar App ID

1. **Criar APNs Auth Key** (se ainda não fez)
   - Vá em: https://developer.apple.com/account/resources/authkeys/list
   - Crie a key com APNs habilitado

2. **Configurar no Firebase Console**
   - Faça upload da APNs Auth Key
   - Configure o Bundle ID

3. **Configurar no Xcode**
   - Verifique se o Bundle ID no Xcode corresponde
   - Configure Signing & Capabilities

---

## ⚠️ Importante

- **Push Notifications é OBRIGATÓRIO** para receber notificações push
- **Background Modes → Remote notifications** é necessário para receber notificações quando o app está em background
- Você pode editar as capabilities depois, mas é melhor configurar tudo agora
- O App ID precisa estar criado antes de fazer upload para TestFlight

---

**Status:** ✅ Pronto para configurar!  
**Tempo estimado:** 2-5 minutos
