# 🔐 Como Obter Certificado APNs para Push Notifications

## 📋 O que são os arquivos .p8 e .p12?

Esses são certificados da Apple para enviar notificações push. Você precisa criar um no Apple Developer Portal.

---

## ✅ Método Recomendado: APNs Auth Key (.p8)

### Passo 1: Acessar Apple Developer Portal

1. Acesse: https://developer.apple.com/account/resources/authkeys/list
2. Faça login com sua conta Apple Developer
3. Se não tiver conta, crie em: https://developer.apple.com/programs/

### Passo 2: Criar Auth Key

1. Clique no botão **+** (criar nova key)
2. Preencha:
   - **Key Name:** `DailyMovieChallenge APNs Key` (ou qualquer nome)
   - **Enable Apple Push Notifications service (APNs)**
3. Clique em **Continue**
4. Clique em **Register**

### Passo 3: Download da Key

1. **IMPORTANTE:** Você só pode baixar a key UMA VEZ!
2. Clique em **Download**
3. O arquivo será baixado como `AuthKey_XXXXXXXXXX.p8`
4. **Guarde este arquivo em local seguro!** Você não poderá baixá-lo novamente.

### Passo 4: Anotar o Key ID

1. Na página da key, anote o **Key ID** (ex: `ABC123XYZ`)
2. Você precisará dele no Firebase

---

## 🔄 Método Alternativo: APNs Certificate (.p12)

Se preferir usar certificado em vez de Auth Key:

### Passo 1: Criar Certificate

1. Acesse: https://developer.apple.com/account/resources/certificates/list
2. Clique em **+** (criar novo certificado)
3. Selecione **Apple Push Notification service SSL (Sandbox & Production)**
4. Selecione seu **App ID** (ou crie um novo)
5. Siga as instruções para criar um Certificate Signing Request (CSR)
6. Faça upload do CSR
7. Baixe o certificado (.cer)

### Passo 2: Converter para .p12

1. Abra o **Keychain Access** no Mac
2. Importe o certificado .cer
3. Expanda o certificado e exporte como .p12
4. Defina uma senha (você precisará dela no Firebase)

---

## 📤 Upload no Firebase Console

### Usando Auth Key (.p8) - Recomendado

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione o projeto **movie-daily-dev**
3. Vá em **Project Settings** (ícone de engrenagem)
4. Vá na aba **Cloud Messaging**
5. Na seção **Apple app configuration**:
   - Clique em **Upload**
   - Selecione o arquivo `.p8` que você baixou
   - Cole o **Key ID** que você anotou
   - Clique em **Upload**

### Usando Certificate (.p12) - Alternativo

1. Mesmo processo acima
2. Selecione o arquivo `.p12`
3. Digite a senha que você definiu ao exportar

---

## ✅ Verificação

Após fazer upload, você deve ver:
- ✅ Status: "Active" ou "Configurado"
- ✅ Data de upload

---

## 🐛 Problemas Comuns

### "Não tenho conta Apple Developer"
- **Solução:** Crie uma conta em https://developer.apple.com/programs/
- **Custo:** $99/ano (necessário para push notifications em produção)
- **Alternativa para testes:** Use o simulador (mas não recebe notificações push)

### "Não encontro a opção APNs"
- Certifique-se de estar logado com conta Apple Developer (não apenas Apple ID)
- Verifique se sua conta tem acesso ao programa de desenvolvedor

### "Perdi o arquivo .p8"
- Infelizmente, você não pode baixar novamente
- Precisa criar uma nova key e fazer upload no Firebase novamente

### "O Firebase não aceita o arquivo"
- Verifique se o arquivo não está corrompido
- Certifique-se de que o Key ID está correto (para .p8)
- Verifique se a senha está correta (para .p12)

---

## 📝 Resumo

1. **Criar Auth Key (.p8)** no Apple Developer Portal
2. **Baixar o arquivo** (apenas uma vez!)
3. **Anotar o Key ID**
4. **Fazer upload no Firebase Console** → Project Settings → Cloud Messaging
5. **Pronto!** As notificações push devem funcionar

---

## ⚠️ Importante

- **Guarde o arquivo .p8 em local seguro** - você não pode baixá-lo novamente
- **Anote o Key ID** - você precisará dele no Firebase
- **Para produção:** Você precisa de uma conta Apple Developer paga ($99/ano)
- **Para testes:** Use dispositivo físico (simulador não recebe push notifications)
