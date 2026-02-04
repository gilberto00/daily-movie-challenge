# 📱 Integração Facebook – Pesquisa e Sugestões

Pesquisa sobre como jogos mobile atuais integram redes sociais e sugestões para o **Daily Movie Challenge** começar com Facebook.

---

## 🔍 O que jogos mobile fazem hoje

- **+90% dos top 100** jogos mobile (iOS/Android) nos EUA usam integração Facebook.
- **Facebook Login** é central: conversão de ~85% quando bem destacado (progresso em nuvem, desafios com amigos).
- **Compartilhamento**: compartilhar em momentos de conquista (nível, high score, conquista) aumenta aquisição orgânica.
- **Superfícies**: Feed, Stories, Messenger e Facebook Groups — quanto mais opções, maior o alcance.

---

## 🎯 Opções de integração Facebook (do mais simples ao mais completo)

### Opção 1 – Share nativo (ShareDialog) – **Recomendado para começar**
- **O que é:** Usa `FBSDKShareKit` para abrir o Share Dialog do Facebook diretamente.
- **O que compartilha:** Link + título + descrição + imagem (Open Graph).
- **Complexidade:** Baixa (SDK + configuração no Facebook Developer).
- **Não exige:** Login com Facebook, Gaming Services.
- **Ideal para:** Compartilhar resultado/streak com link do app e imagem atraente.

### Opção 2 – Sharing for Gaming (imagem/vídeo)
- **O que é:** Share de screenshots ou vídeos para Feed, Stories, Instagram.
- **O que compartilha:** Imagem (ex.: pôster do filme + streak) ou vídeo.
- **Complexidade:** Média (enrolar em Gaming Services, upload de assets).
- **Exige:** Gaming Services habilitado no app Facebook.
- **Ideal para:** Conteúdo visual forte (resultado com pôster do filme).

### Opção 3 – Facebook Login + compartilhamento
- **O que é:** Login com Facebook como opção de autenticação.
- **Benefícios:** Perfil público, amigos, convites, compartilhamento personalizado.
- **Complexidade:** Média–alta (mudar fluxo de auth).
- **Ideal para:** Versão futura com desafios entre amigos.

### Opção 4 – Gaming Services completo
- **O que é:** Suíte de recursos (Login, Sharing, Game Requests, Analytics).
- **Complexidade:** Alta.
- **Ideal para:** Jogo com foco em multiplayer e comunidade.

---

## ✅ Sugestão para o Daily Movie Challenge

### Fase 1 – Share nativo (ShareDialog) – **começar aqui**
1. Adicionar **Facebook SDK for iOS** (ou só FBSDKShareKit).
2. Criar **App no [Facebook Developers](https://developers.facebook.com/)**.
3. Configurar **Open Graph** (título, descrição, imagem) para o link do app.
4. No botão **Compartilhar**, além do `UIActivityViewController`, chamar **ShareDialog** do Facebook.
5. Texto sugerido: *"Acertei o desafio do Daily Movie Challenge hoje! Streak: X. Consegue bater? [link]"*.

**Vantagens:** Implementação simples, experiência nativa do Facebook, link + imagem no feed.

---

### Fase 2 – Imagem customizada (Sharing for Gaming)
1. Enrolar o app em **Gaming Services**.
2. Gerar imagem de share (ex.: pôster do filme + streak + logo).
3. Usar **Sharing for Gaming** para publicar essa imagem no Feed/Stories/Instagram.

**Vantagens:** Conteúdo mais visual e mais provável de ser compartilhado.

---

### Fase 3 – Facebook Login (opcional, futuro)
- Oferecer login com Facebook como opção.
- Sincronizar progresso, desafios entre amigos, convites.

---

## 📋 Passos práticos – Fase 1 (Share nativo)

### 1. Criar App no Facebook Developers
1. Acesse [developers.facebook.com](https://developers.facebook.com/) → **My Apps** → **Create App**.
2. Tipo: **Consumer** (ou **Gaming** se for usar Gaming Services depois).
3. Anote o **App ID**.

### 2. Configurar o app iOS no Facebook
1. **Settings** → **Basic** → adicionar plataforma **iOS**.
2. Bundle ID: `com.gilbertorosa.cinedaily`.
3. Em **Info.plist**, adicionar:
   - `FacebookAppID`
   - `FacebookDisplayName`
   - `LSApplicationQueriesSchemes` (para `fbapi`, `fb-messenger-share-api`)

### 3. Adicionar Facebook SDK ao projeto
- **Swift Package Manager:** `https://github.com/facebook/facebook-ios-sdk`
- Pacotes sugeridos: `FacebookCore`, `FacebookShare`.

### 4. Implementar ShareDialog
```swift
import FacebookShare

// Criar conteúdo de share
let content = ShareLinkContent()
content.contentURL = URL(string: "https://apps.apple.com/app/seu-app-id")!
content.quote = "Acertei o desafio do Daily Movie Challenge hoje! Streak: \(streak). Consegue bater?"

let dialog = ShareDialog(
    viewController: uiViewController,
    content: content,
    delegate: self
)
dialog.mode = .automatic // abre Facebook se instalado, senão web
dialog.show()
```

### 5. Open Graph (opcional)
- No [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/) configurar meta tags para o link.
- Garante título, descrição e imagem corretos ao compartilhar o link.

---

## 📚 Documentação útil

- [Sharing on iOS](https://developers.facebook.com/docs/sharing/ios/)
- [Share Dialog](https://developers.facebook.com/docs/sharing/reference/share-dialog)
- [Sharing for Native Apps (Gaming)](https://developers.facebook.com/docs/games/acquire/sharing/native-apps/)
- [Facebook SDK for iOS](https://developers.facebook.com/docs/ios/getting-started/)
- [Gaming Services – Enroll](https://developers.facebook.com/docs/games/gaming-services/enroll)

---

## Resumo

| Fase | O que fazer | Esforço |
|------|-------------|---------|
| **1** | ShareDialog (link + imagem OG) | Baixo |
| **2** | Sharing for Gaming (imagem custom) | Médio |
| **3** | Facebook Login | Médio–Alto |

Recomendação: começar pela **Fase 1** para ter compartilhamento nativo no Facebook com pouco esforço.
