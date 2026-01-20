# 🔧 Como Corrigir o Erro de Autenticação

## ❌ Erro Atual

```
Error: Could not authenticate
This operation is restricted to administrators only.
```

## ✅ Solução: Habilitar Autenticação Anônima no Firebase

O app está rodando, mas a **Autenticação Anônima** não está habilitada no Firebase Console.

### Passo 1: Acessar Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Selecione o projeto: **movie-daily-dev**

### Passo 2: Habilitar Sign-in Anônimo

1. No menu lateral, clique em **"Authentication"** (Autenticação)
2. Clique na aba **"Sign-in method"** (Método de login)
3. Você verá uma lista de providers
4. Procure por **"Anonymous"** (Anônimo) na lista
5. Clique em **"Anonymous"**
6. **Ative o toggle** para habilitar
7. Clique em **"Save"** (Salvar)

### Passo 3: Verificar Firestore Rules

Certifique-se de que as regras do Firestore permitem autenticação anônima:

1. No Firebase Console, vá em **"Firestore Database"**
2. Clique na aba **"Rules"** (Regras)
3. As regras devem permitir usuários autenticados (mesmo anonimamente)
4. As regras que criamos já estão corretas, mas verifique:

```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

Isso permite usuários autenticados (incluindo anônimos).

### Passo 4: Testar Novamente

1. Feche o app no simulador
2. Execute novamente no Xcode (Cmd+R)
3. O erro deve desaparecer

## 📋 Checklist

- [ ] Firebase Console aberto
- [ ] Projeto "movie-daily-dev" selecionado
- [ ] Authentication → Sign-in method → Anonymous → HABILITADO
- [ ] Salvar alterações
- [ ] Executar app novamente

## ⚠️ Nota Importante

A autenticação anônima é **necessária** para o MVP funcionar. Sem ela, o app não consegue:
- Criar usuários no Firestore
- Rastrear streak
- Funcionar corretamente

Depois de habilitar, o app deve funcionar normalmente! 🎉
