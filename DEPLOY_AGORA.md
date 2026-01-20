# 🚨 DEPLOY URGENTE - LEIA ANTES DE TESTAR NOVAMENTE

## ✅ PROBLEMA IDENTIFICADO E CORRIGIDO

**O que estava errado:**
- Os arquivos da Cloud Function estavam apenas em `DailyMovieChallenge_temp/`
- A pasta `functions/` no projeto principal estava **VAZIA**
- Faltavam arquivos de configuração do Firebase (`.firebaserc`, `firebase.json`, etc.)

**O que foi corrigido:**
- ✅ Criado `.firebaserc` com projeto Firebase correto (`movie-daily-dev`)
- ✅ Criado todos os arquivos em `functions/`:
  - `package.json`
  - `tsconfig.json`
  - `.gitignore`
  - `src/index.ts` (Cloud Function principal)
  - `src/utils/tmdb.ts` (integração TMDB)
  - `src/utils/questionGenerator.ts` (geração de perguntas)
- ✅ Configurado `firebase.json` e `firestore.rules`

---

## 🚀 AGORA VOCÊ PRECISA FAZER O DEPLOY

**A Cloud Function ainda NÃO está deployada no Firebase.** Isso precisa ser feito manualmente no terminal.

### 📋 PASSOS OBRIGATÓRIOS (execute no Terminal):

```bash
# 1. Vá até a pasta do projeto
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

# 2. Verifique se está no projeto Firebase correto
firebase use
# Deve mostrar: "Using project 'movie-daily-dev'"

# 3. Instale as dependências da Cloud Function
cd functions
npm install

# 4. Volte para a raiz e faça o deploy
cd ..
npx firebase-tools deploy --only functions:getDailyChallenge
```

### ✅ Correção do erro de versão do Node (Node 18 descontinuado)

Eu já atualizei o seu `package.json` para usar **Node 22**. Agora o deploy deve funcionar.

---

### 🚀 TENTE O DEPLOY NOVAMENTE AGORA:

No seu Terminal (dentro da pasta `functions` onde você parou):

```bash
cd ..
npx firebase-tools deploy --only functions:getDailyChallenge
```

### ✅ Alternativa se `firebase` e `npm -g` derem erro (recomendado)

Use `npx` para não precisar instalar globalmente:

```bash
# 1. Vá até a pasta do projeto
cd /Users/gilbertorosa/Documents/Code/DailyMovieChallenge

# 2. Login no Firebase via npx
npx firebase-tools login

# 3. Verifique o projeto
npx firebase-tools use movie-daily-dev

# 4. Instale dependências e faça o deploy
cd functions
npm install
cd ..
npx firebase-tools deploy --only functions:getDailyChallenge
```

### ✅ Correção rápida do erro EACCES no npm (permissão)

Se você quiser instalar o Firebase CLI globalmente sem erro:

```bash
mkdir -p ~/.npm-global
npm config set prefix "~/.npm-global"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
npm install -g firebase-tools
firebase --version
```

**Este comando vai demorar 2-5 minutos** enquanto o Firebase compila e deploya a função.

### ✅ DEPOIS DO DEPLOY BEM-SUCEDIDO:

1. **Teste no navegador primeiro:**
   - Abra: `https://us-central1-movie-daily-dev.cloudfunctions.net/getDailyChallenge`
   - Você deve ver um JSON com o desafio do dia

2. **Execute o app novamente no Xcode:**
   - O erro 404 vai desaparecer
   - O desafio vai carregar automaticamente

---

## 🐛 SE DER ERRO NO DEPLOY

### Erro: "Firebase CLI not found"
```bash
npm install -g firebase-tools
firebase login
```

### Erro: "npm install failed"
Certifique-se de que o Node.js está instalado:
```bash
node --version  # Deve ser 18 ou superior
```

### Erro: "TypeScript compilation failed"
Verifique se há erros de sintaxe nos arquivos `.ts`.

---

## ⚠️ IMPORTANTE

**O erro 404 no app só vai desaparecer DEPOIS que você fizer o deploy da Cloud Function.** Não há como o app funcionar sem a função estar deployada no Firebase.

**Todos os arquivos necessários já foram criados no projeto.** Agora é só fazer o deploy seguindo os passos acima.

---

## 📞 PRECISA DE AJUDA?

Se der algum erro durante o deploy:
1. Copie o erro completo do terminal
2. Me envie a mensagem
3. Eu ajudo a resolver!
