# 🔍 Guia de Debug - Daily Movie Challenge

## 📊 Logs Adicionados

Adicionei logs detalhados em todos os pontos críticos do app para identificar problemas:

### 🚀 App Initialization
- Verifica se Firebase está configurado
- Verifica se GoogleService-Info.plist foi encontrado

### 🔐 Authentication Flow
- Logs em cada etapa da autenticação anônima
- Logs de criação de usuário no Firestore
- Erros detalhados com tipo e código

### 📡 Network Requests
- URL completa sendo chamada
- HTTP status code
- Headers da resposta
- Tamanho dos dados recebidos
- Erros de decodificação JSON

### 📝 Firestore Operations
- Operações de leitura/escrita
- Status de documentos
- Erros com detalhes completos

## 📱 Como Ver os Logs

### No Xcode:
1. Abra o **Debug Console** (⌘⇧Y ou View → Debug Area → Show Debug Area)
2. Execute o app (Cmd+R)
3. Os logs aparecem no console com emojis para facilitar identificação:
   - 🚀 App initialization
   - 🔐 Authentication
   - 📡 Network requests
   - ✅ Success
   - ❌ Errors
   - ⚠️ Warnings
   - 🔄 Operations in progress

### Procurar por Erros:
- Procure por **❌** para ver erros
- Procure por **⚠️** para ver warnings
- Procure por **[ChallengeService]** para ver erros de rede
- Procure por **[AuthViewModel]** para ver erros de autenticação

## 🔍 Identificando o Problema Atual

Com base no erro "Network error", procure no console por:

1. **`[ChallengeService] Fetching challenge from:`** - Verifica se a URL está correta
2. **`[ChallengeService] HTTP Status:`** - Verifica o código HTTP (404 = não encontrado, 500 = erro servidor)
3. **`[ChallengeService] Response body:`** - Vê o que o servidor retornou
4. **`[ChallengeService] Decoding error:`** - Problema ao decodificar JSON

## ✅ Próximos Passos

1. **Execute o app no Xcode**
2. **Abra o Debug Console (⌘⇧Y)**
3. **Copie os logs que aparecem com ❌**
4. **Me envie os logs para análise**

Os logs vão mostrar exatamente onde está falhando! 🔍
