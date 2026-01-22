# 🚨 DEPLOY DAS REGRAS DO FIRESTORE - LEADERBOARD

## ⚠️ PROBLEMA IDENTIFICADO

O erro no console mostra:
```
Missing or insufficient permissions
Listen for query at users|f:|ob:scoredesc__name__desc|1:100|lt:f failed
```

Isso significa que **as regras do Firestore não estão deployadas** ou não estão permitindo a leitura pública da coleção `users` (necessária para o leaderboard).

---

## ✅ SOLUÇÃO: DEPLOY DAS REGRAS

Execute no Terminal:

```bash
# 1. Vá até a pasta do projeto
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

# 2. Deploy das regras do Firestore
npx firebase-tools deploy --only firestore:rules

# 3. Deploy dos índices (se necessário)
npx firebase-tools deploy --only firestore:indexes
```

---

## 📋 O QUE AS REGRAS FAZEM

As regras atuais permitem:
- ✅ **Leitura pública** da coleção `users` (necessário para leaderboard)
- ✅ **Escrita** apenas pelo próprio usuário autenticado
- ✅ **Leitura pública** de `dailyChallenges` e `comments`

---

## 🔍 VERIFICAÇÃO

Após o deploy, você deve ver:
```
✔  Deploy complete!
```

E o erro de permissões no console do app deve desaparecer.

---

## 💡 SOBRE O LEADERBOARD

**Não precisa de cadastro de usuários!** O app usa **autenticação anônima**, então:
- Cada dispositivo tem um `userId` único automaticamente
- O usuário é criado no Firestore na primeira autenticação
- As estatísticas são atualizadas automaticamente quando você responde perguntas

**O leaderboard atualiza quando:**
1. Você responde uma pergunta (correta ou incorreta)
2. O sistema atualiza suas estatísticas (score, streak, accuracy, etc.)
3. Você abre a tela de Leaderboard

---

## 🐛 SE AINDA NÃO FUNCIONAR

1. **Verifique se o usuário foi criado no Firestore:**
   - Firebase Console → Firestore Database
   - Coleção `users` → Deve ter um documento com seu `userId`

2. **Verifique se as estatísticas estão sendo atualizadas:**
   - Após responder uma pergunta, verifique no Firestore se os campos `totalChallenges`, `score`, etc. foram atualizados

3. **Verifique os logs do console:**
   - Procure por mensagens de erro relacionadas a Firestore
