# 🚀 Deploy Cloud Function - PASSO A PASSO COMPLETO

## ⚠️ Erro Atual no App

```
Error loading challenge
Cloud Function not found. Please deploy the function first.
Code: 3
```

**Significa:** A Cloud Function `getDailyChallenge` não está deployada no Firebase.

---

## ✅ SOLUÇÃO: Deploy da Cloud Function

### 📋 Pré-requisitos

Antes de começar, verifique se você tem:

1. **Node.js instalado** (versão 18+)
   ```bash
   node --version
   ```
   Se não tiver, instale em: https://nodejs.org/

2. **Firebase CLI instalado:**
   ```bash
   npm install -g firebase-tools
   ```

3. **Logado no Firebase:**
   ```bash
   firebase login
   ```
   Isso abrirá o navegador para autenticação.

---

## 🚀 PASSO A PASSO DO DEPLOY

### 1. Abra o Terminal

Abra o Terminal no Mac (Applications → Utilities → Terminal).

### 2. Navegue até a pasta do projeto

```bash
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge
```

### 3. Verifique se está no projeto correto do Firebase

```bash
firebase use
```

Você deve ver: `Using project 'movie-daily-dev'`

Se não estiver correto, configure:
```bash
firebase use movie-daily-dev
```

### 4. Instale as dependências da Cloud Function

```bash
cd functions
npm install
```

Isso pode demorar alguns minutos na primeira vez.

**Você deve ver:**
```
added 150 packages in 30s
```

### 5. Teste o build localmente (opcional mas recomendado)

```bash
npm run build
```

**Você deve ver:**
```
> daily-movie-challenge-functions@1.0.0 build
> tsc
```

**Se houver erros**, me avise e eu corrijo.

### 6. Volte para a raiz do projeto

```bash
cd ..
```

### 7. Deploy da Cloud Function

```bash
firebase deploy --only functions:getDailyChallenge
```

**Este passo pode demorar 2-5 minutos.** O Firebase vai:
- Compilar o TypeScript
- Fazer upload do código
- Deploy da função na região `us-central1`

**Você deve ver algo como:**
```
✔  functions[getDailyChallenge(us-central1)] Successful create operation.
Function URL (getDailyChallenge): https://us-central1-movie-daily-dev.cloudfunctions.net/getDailyChallenge
```

✅ **Anote este URL!** É o que o app usa para chamar a função.

---

## 🔄 DEPOIS DO DEPLOY

### 1. Teste a função no navegador

Abra no navegador:
```
https://us-central1-movie-daily-dev.cloudfunctions.net/getDailyChallenge
```

**Você deve ver um JSON com:**
- `id`: Data do desafio (ex: "2026-01-19")
- `title`: Nome do filme
- `question`: Pergunta sobre o ano
- `options`: Array com 4 alternativas
- `correctAnswer`: Resposta correta
- `curiosity`: Curiosidade sobre o filme
- `posterUrl`: URL do poster

### 2. Atualize o app no simulador

1. **Feche o app no simulador** (swipe up ou Cmd+Q)
2. **Execute novamente no Xcode** (Cmd+R)
3. **O erro deve desaparecer!** ✨
4. **Você deve ver o desafio do dia carregado!** 🎉

---

## 📝 DEPLOY DAS REGRAS DO FIRESTORE (se ainda não fez)

As regras do Firestore também precisam estar deployadas para o app funcionar completamente:

```bash
firebase deploy --only firestore:rules
```

**Você deve ver:**
```
✔  firestore: released rules firestore.rules to cloud.firestore
```

---

## 🐛 SOLUÇÃO DE PROBLEMAS

### Erro: "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### Erro: "Not logged in"
```bash
firebase login
```

### Erro: "Project not found"
```bash
firebase use movie-daily-dev
```

### Erro: "npm install failed"
Certifique-se de que o Node.js está instalado:
```bash
node --version  # Deve ser 18 ou superior
```

### Erro: "TypeScript compilation failed"
Verifique se há erros de sintaxe nos arquivos `.ts` na pasta `functions/src/`.

### A função está deployada mas o app ainda mostra erro 404

1. **Verifique o URL no app:**
   - O código usa: `https://us-central1-movie-daily-dev.cloudfunctions.net/getDailyChallenge`
   - Deve corresponder ao URL mostrado após o deploy

2. **Verifique os logs da função:**
   ```bash
   firebase functions:log --only getDailyChallenge
   ```

3. **Teste no navegador primeiro** antes de testar no app

---

## ✅ VERIFICAÇÃO FINAL

Depois do deploy bem-sucedido:

1. ✅ Função está acessível no navegador
2. ✅ Retorna JSON válido
3. ✅ App carrega o desafio sem erros
4. ✅ HomeView mostra o filme e o botão "Play"

---

## 📚 COMANDOS ÚTEIS

```bash
# Ver logs da função
firebase functions:log --only getDailyChallenge

# Listar todas as funções deployadas
firebase functions:list

# Deletar uma função (se necessário)
firebase functions:delete getDailyChallenge

# Ver status do deploy
firebase deploy --only functions --dry-run
```

---

## ⚠️ NOTA IMPORTANTE

**Sem a Cloud Function deployada**, o app não consegue:
- ❌ Carregar o desafio do dia
- ❌ Gerar perguntas sobre filmes
- ❌ Funcionar completamente

**Depois do deploy**, tudo deve funcionar! 🎉

---

## 🆘 PRECISA DE AJUDA?

Se encontrar algum problema durante o deploy:
1. Copie o erro completo do terminal
2. Me envie a mensagem de erro
3. Eu ajudo a resolver! 😊
