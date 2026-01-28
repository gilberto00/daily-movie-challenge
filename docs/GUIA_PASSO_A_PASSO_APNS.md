# 🔐 Guia Passo a Passo: Configurar APNs no Firebase

## 📍 Onde você está agora

Você está na tela correta do Firebase Console:
- **Projeto:** movie-daily-dev
- **App iOS:** CineDaily iOS (com.seunome.cinedaily)
- **Seção:** Cloud Messaging → APNs Configuration

---

## ✅ PASSO 1: Criar APNs Auth Key no Apple Developer Portal

### 1.1 Acessar o Portal

1. Abra uma nova aba no navegador
2. Acesse: **https://developer.apple.com/account/resources/authkeys/list**
3. Faça login com sua conta Apple Developer

### 1.2 Criar a Auth Key

1. Clique no botão **+** (criar nova key) no canto superior direito
2. Preencha o formulário:
   - **Key Name:** `CineDaily APNs Key` (ou qualquer nome descritivo)
   - **Enable:** ✅ Marque **Apple Push Notifications service (APNs)**
3. Clique em **Continue**
4. Revise as informações e clique em **Register**

### 1.3 Download da Key

⚠️ **ATENÇÃO:** Você só pode baixar a key UMA VEZ!

1. Na página de confirmação, clique em **Download**
2. O arquivo será baixado como: `AuthKey_XXXXXXXXXX.p8`
3. **Guarde este arquivo em local seguro!** (você não poderá baixá-lo novamente)

### 1.4 Anotar Informações

Na mesma página, você verá:

- **Key ID:** (ex: `ABC123XYZ`) - **ANOTE ESTE VALOR!**
- **Team ID:** (ex: `XYZ123ABC`) - aparece no canto superior direito do portal

**Exemplo do que você verá:**
```
Key ID: ABC123XYZ
Team ID: XYZ123ABC
```

---

## ✅ PASSO 2: Upload no Firebase Console

### 2.1 Voltar para o Firebase

Volte para a aba do Firebase Console onde você está agora.

### 2.2 Upload da Development Key

1. Na seção **"APNs Authentication Key"**
2. Na linha **"Development"**, clique no botão **Upload**
3. Uma janela modal aparecerá:
   - **Upload APNs Auth Key file:** Clique em "Choose file" e selecione o arquivo `.p8` que você baixou
   - **Key ID:** Cole o Key ID que você anotou (ex: `ABC123XYZ`)
   - **Team ID:** Cole o Team ID que você anotou (ex: `XYZ123ABC`)
4. Clique em **Upload**

### 2.3 Upload da Production Key

**IMPORTANTE:** Para desenvolvimento, você pode usar a mesma key para Development e Production.

1. Na linha **"Production"**, clique no botão **Upload**
2. Use o **mesmo arquivo .p8** e as **mesmas informações** (Key ID e Team ID)
3. Clique em **Upload**

---

## ✅ PASSO 3: Verificar Configuração

Após o upload, você deve ver:

### Development:
- ✅ **File:** `AuthKey_XXXXXXXXXX.p8`
- ✅ **Key ID:** (seu Key ID)
- ✅ **Team ID:** (seu Team ID)
- ✅ **Actions:** (ícone de lixeira para deletar, se necessário)

### Production:
- ✅ **File:** `AuthKey_XXXXXXXXXX.p8`
- ✅ **Key ID:** (seu Key ID)
- ✅ **Team ID:** (seu Team ID)
- ✅ **Actions:** (ícone de lixeira para deletar, se necessário)

---

## 🎯 Próximos Passos

Após configurar o APNs:

1. **Verificar Xcode:**
   - Abra o projeto no Xcode
   - Verifique se as capabilities estão configuradas (Push Notifications, Background Modes)

2. **Deploy das Cloud Functions:**
   ```bash
   cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
   ./deploy_push_notifications.sh
   ```

3. **Testar no Dispositivo:**
   - Execute o app em um dispositivo físico (simulador não recebe push)
   - Aceite a permissão de notificações
   - Verifique se o token FCM foi salvo no Firestore

---

## 🐛 Problemas Comuns

### "Não consigo criar Auth Key"
- Verifique se sua conta Apple Developer está ativa
- Verifique se você tem permissões de Admin ou Account Holder
- Tente em outro navegador ou limpe o cache

### "Firebase não aceita o arquivo .p8"
- Verifique se o arquivo não está corrompido
- Verifique se o Key ID está correto (sem espaços extras antes/depois)
- Verifique se o Team ID está correto
- Tente fazer upload novamente

### "Key ID ou Team ID incorreto"
- Volte ao Apple Developer Portal
- Na página da key, você verá o Key ID
- O Team ID aparece no canto superior direito do portal (ao lado do seu nome)

### "Não encontro a opção APNs"
- Certifique-se de estar logado com conta Apple Developer (não apenas Apple ID)
- Verifique se sua conta tem acesso ao programa de desenvolvedor
- A opção deve aparecer como "Apple Push Notifications service (APNs)"

---

## 📝 Resumo Rápido

1. ✅ **Apple Developer Portal:** Criar Auth Key → Download `.p8` → Anotar Key ID e Team ID
2. ✅ **Firebase Console:** Upload do `.p8` → Colar Key ID → Colar Team ID → Upload
3. ✅ **Verificar:** Ambos (Development e Production) devem mostrar status configurado
4. ✅ **Próximo:** Deploy das Cloud Functions e testar no dispositivo

---

## ⚠️ Importante

- **Guarde o arquivo .p8 em local seguro** - você não pode baixá-lo novamente
- **Anote o Key ID e Team ID** - você precisará deles se recriar a configuração
- **Use a mesma key para Development e Production** - é mais simples e funciona para ambos
- **Dispositivo físico necessário** - simulador iOS não recebe push notifications

---

**Status:** ✅ Pronto para configurar!  
**Tempo estimado:** 5-10 minutos
