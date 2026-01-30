# Lista de melhorias prioritárias – Daily Movie Challenge

Lista consolidada com os pontos que você escolheu, em ordem sugerida para implementação.

---

## 1. Localização (PT-BR e fr-CA) ✅

**Objetivo:** Todo o app em português do Brasil e francês do Canadá para os testadores e usuários.

**Tarefas:**
- [x] Criar `Localizable.strings` para en, pt-BR e fr-CA no projeto
- [x] Traduzir strings da UI: HomeView, TriviaView, ResultView, LeaderboardView, NotificationSettingsView, ContentView, CommentsView
- [x] Trocar textos fixos por `String(localized:)` e `String(format: String(localized:), ...)` onde há parâmetros
- [ ] (Opcional) Traduzir perguntas e curiosidades no backend (Cloud Function) ou manter em inglês e só UI localizada

**Benefício:** Mais engajamento e sensação de app “nosso”.

---

## 2. Nomes no leaderboard (em vez de só “Player”)

**Objetivo:** No ranking, mostrar nome ou apelido do jogador em vez de “Player” para todos.

**Situação atual:** O modelo `LeaderboardEntry` já tem `username: String?`, mas o Firestore não grava nem lê esse campo; no código está sempre `username: nil`.

**Tarefas:**
- [ ] Adicionar campo `displayName` (ou `username`) no documento do usuário no Firestore (`users/{userId}`)
- [ ] Tela ou fluxo para o usuário definir apelido/nome (ex.: tela de perfil ou prompt no primeiro uso)
  - Regras: tamanho máximo, caracteres permitidos, opcional (quem não definir continua como “Jogador” ou “Player” até trocar)
- [ ] Ao criar/atualizar perfil, salvar `displayName` no Firestore
- [ ] Em `FirestoreService.fetchLeaderboard`, ler `displayName` (ou `username`) do documento e passar para `LeaderboardEntry`
- [ ] Em `LeaderboardViewModel`, ao montar `currentUserEntry` a partir do documento do usuário, usar o mesmo campo
- [ ] Na UI do leaderboard, exibir `entry.username ?? "Jogador"` (ou “Player” se ainda não tiver PT-BR)

**Benefício:** Ranking mais pessoal e reconhecível.

---

## 3. Botão compartilhar

**Objetivo:** Usuário poder compartilhar o resultado do desafio do dia (ex.: “Acertei o desafio! Streak: X”) em redes sociais e mensagens.

**Tarefas:**
- [ ] Na `ResultView`, após responder o **desafio do dia**, mostrar botão “Compartilhar”
- [ ] Texto sugerido: “Acertei o desafio do Daily Movie Challenge hoje! Streak: X” (ajustar depois para PT-BR)
- [ ] Usar `UIActivityViewController` (share sheet) no iOS: texto + opcionalmente link do app na App Store
- [ ] (Opcional) Pré-preencher imagem (poster do filme do dia ou ícone do app) no share

**Benefício:** Divulgação orgânica e reforço da conquista (streak).

---

## 4. Propor desafios para outros jogadores (integração com rede social)

**Objetivo:** Usuário poder “desafiar” amigos a jogar o desafio do dia, com integração a redes sociais (Facebook ou similar) e/ou compartilhamento genérico.

**Opções de implementação (do mais simples ao mais integrado):**

**Opção A – Compartilhamento genérico (recomendado para começar)**  
- Mesmo botão “Compartilhar” da seção 3, com texto de desafio: “Consegue acertar o desafio do dia? Baixe o app e me desafie!” + link do app  
- Funciona para Facebook, WhatsApp, Twitter, etc., sem SDK específico  
- Tarefas: incluir no share sheet um texto de “desafio” além do “resultado”; opcional: botão “Desafiar amigos” que abre o share com esse texto

**Opção B – Link “Desafiar amigo” (deep link)**  
- Link que abre o app (ex.: `dailymoviechallenge://challenge/today` ou link universal) na tela do desafio do dia ou na home  
- Amigo que clica baixa/abre o app e vê o mesmo desafio do dia  
- Tarefas: configurar link universal ou URL scheme para “desafio do dia”; página web opcional que redireciona para a App Store ou abre o app

**Opção C – Integração com Facebook (mais trabalho)**  
- Facebook SDK: login com Facebook (opcional) e/ou share nativo no Facebook  
- “Compartilhar no Facebook” com texto + link (e talvez imagem)  
- Tarefas: adicionar Facebook SDK, configurar App no Facebook Developer, tela de share ou uso do share sheet com foco em Facebook

**Sugestão:** Começar com **Opção A** (compartilhar com texto de “desafio”) e **Opção B** (link que abre o app no desafio). Depois, se fizer sentido, evoluir para Opção C.

**Tarefas sugeridas (fase 1):**
- [ ] Botão “Desafiar amigos” na ResultView (ou na Home, após jogar o desafio do dia)
- [ ] Share sheet com texto: “Consegue acertar o desafio do dia? [link do app]” e opcionalmente resultado/streak
- [ ] Deep link ou link universal para “desafio do dia” (quem recebe abre o app na home ou no desafio)
- [ ] (Fase 2) Página web simples que mostra “Você foi desafiado!” e botão “Baixar o app” / “Abrir no app”

**Benefício:** Crescimento por indicação e mais jogadores entrando pelo desafio.

---

## Resumo da lista (ordem sugerida)

| # | Item | Dependências |
|---|------|----------------|
| 1 | Localização (PT-BR) | Nenhuma |
| 2 | Nomes no leaderboard | Nenhuma (campo no Firestore + tela de perfil/nickname) |
| 3 | Botão compartilhar | Pode ser feito junto com o item 4 |
| 4 | Propor desafios (share + link “desafiar amigo”) | Botão compartilhar ajuda; deep link já existe em parte |

---

## Próximo passo

O **item 1 (localização)** está feito. Lembrete dos itens seguintes para as próximas sprints:

- **Item 2 – Nomes no leaderboard:** Campo `displayName` no Firestore, tela para definir apelido, ler no `fetchLeaderboard` e exibir em vez de só "Player".
- **Item 3 – Botão compartilhar:** Na ResultView, após o desafio do dia, botão "Compartilhar" com share sheet (texto + link do app).
- **Item 4 – Propor desafios (rede social):** Botão "Desafiar amigos", share com texto de desafio + link que abre o app; opcional: integração Facebook.

Quando quiser, podemos detalhar e implementar o **2**, o **3** ou o **4** em tarefas por arquivo.
