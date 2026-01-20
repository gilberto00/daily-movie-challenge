# 🚀 Deploy Firestore Rules - CORRIGIR ERRO

## ⚠️ Problema Atual

O erro "Missing or insufficient permissions" acontece porque as **regras do Firestore não estão deployadas** no Firebase.

## ✅ Solução: Deploy das Regras

### Pré-requisitos

1. **Firebase CLI instalado:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Logado no Firebase:**
   ```bash
   firebase login
   ```

### Deploy das Regras

1. **Abra o Terminal**

2. **Navegue até a pasta do projeto:**
   ```bash
   cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
   ```

3. **Configure o projeto (se ainda não fez):**
   ```bash
   firebase use movie-daily-dev
   ```

4. **Deploy das regras do Firestore:**
   ```bash
   firebase deploy --only firestore:rules
   ```

5. **Aguarde a confirmação:**
   - Você deve ver "Deploy complete!"

### Verificar no Firebase Console

1. Acesse: https://console.firebase.google.com/project/movie-daily-dev/firestore/rules
2. Você deve ver as regras deployadas
3. Verifique que a regra para `users/{userId}` permite autenticação anônima

## 🔄 Depois do Deploy

1. **Feche o app no simulador**
2. **Execute novamente no Xcode (Cmd+R)**
3. **O erro deve desaparecer**

## 📝 Regras que serão deployadas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: usuário autenticado pode ler/escrever seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Daily Challenges: leitura pública
    match /dailyChallenges/{date} {
      allow read: if true;
      allow write: if false;
    }
    
    // Comments: leitura pública, escrita autenticada
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

Essas regras permitem que usuários autenticados (incluindo anônimos) criem e leiam seus próprios documentos na coleção `users`.
