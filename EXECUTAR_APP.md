# 🚀 Como Executar o App no Simulador iPhone

## 📱 Passo a Passo no Xcode

### 1. Selecionar Simulador
1. No Xcode, na barra superior, clique no dispositivo (atualmente mostra "iPhone 17 Pro")
2. Escolha um simulador iPhone (ex: iPhone 17 Pro, iPhone 15 Pro, etc.)
3. Ou: Window → Devices and Simulators → selecione um simulador

### 2. Build o Projeto
1. **Cmd+B** (ou Product → Build)
2. Aguarde o build completar
3. Verifique se há erros no painel de Issues (⌘5)

### 3. Executar no Simulador
1. **Cmd+R** (ou Product → Run, ou clique no botão ▶️ Play)
2. O simulador deve abrir automaticamente
3. O app será instalado e executado

### 4. Verificar Logs
1. No Xcode, na parte inferior, abra o **Debug Console**
2. Veja os logs para verificar:
   - Se Firebase inicializou
   - Se autenticação anônima funcionou
   - Se há erros de rede ao chamar a Cloud Function

## ⚠️ Possíveis Erros e Soluções

### Erro: "No such module 'FirebaseAuth'"
**Solução:**
- Verifique se o Firebase SDK foi adicionado via SPM
- File → Packages → Reset Package Caches
- Product → Clean Build Folder (Cmd+Shift+K)
- Build novamente

### Erro: "GoogleService-Info.plist not found"
**Solução:**
- Verifique se o arquivo está no target (File Inspector → Target Membership)
- Certifique-se que está na pasta correta: `DailyMovieChallenge/GoogleService-Info.plist`

### Erro: "Cloud Function failed"
**Solução:**
- A Cloud Function precisa estar deployada
- Ou teste localmente primeiro com Firebase Emulator

### Erro de Compilação
**Solução:**
- Product → Clean Build Folder (Cmd+Shift+K)
- Feche e reabra o Xcode
- Build novamente

## ✅ Resultado Esperado

Quando o app executar no simulador, você deve ver:
1. Tela inicial com "Daily Movie Challenge"
2. Indicador de streak
3. Poster do filme (após carregar o challenge)
4. Botão "Play"

**Nota:** Se a Cloud Function não estiver deployada, o app pode mostrar um erro ao tentar carregar o challenge. Isso é esperado!
