# 📱 Plano de Melhorias – Daily Movie Challenge

Documento para priorizar e planejar as próximas evoluções do app, após aprovação no TestFlight e início dos testes externos.

**Lista prioritária (localização, nomes no leaderboard, compartilhar, desafiar amigos):** ver **[LISTA_MELHORIAS_PRIORITARIAS.md](LISTA_MELHORIAS_PRIORITARIAS.md)**.

---

## ✅ O que já temos

- Autenticação (Anonymous / Apple)
- **Desafio do dia** (um por dia, streak correta)
- Trivia: pergunta do ano + perguntas extras (diretor, elenco, etc.) + novo filme
- Resultado com curiosidade, comentários, “jogar outra” / “novo filme”
- Comentários básicos por desafio
- Leaderboard global (score, streak, accuracy, badges)
- Notificações (desafio diário, streak em risco, conquistas)
- Deep linking e tela de configuração de notificações
- TestFlight aprovado para testadores externos

---

## 🎯 Sugestões de melhoria (por prioridade)

### 1. **Localização (PT-BR)** – Alto impacto, esforço médio  
Todo o app está em inglês; a maioria dos testadores é brasileira.

- Traduzir strings da UI (HomeView, TriviaView, ResultView, Leaderboard, Settings)
- Traduzir perguntas e curiosidades no backend (ou manter em inglês e só UI em PT)
- Usar `Localizable.strings` e `String(localized:)` (ou `NSLocalizedString`)

**Benefício:** Mais engajamento e sensação de app “nosso”.

---

### 2. **Completar o sistema de comentários** (já no Sprint 2)  
Só o básico está feito; falta edição, exclusão, likes e moderação.

- [ ] Editar comentário próprio (com indicação “editado”)
- [ ] Excluir comentário próprio
- [ ] Likes em comentários (contador + “curtir/descurtir”)
- [ ] Reportar comentário (moderação básica)
- [ ] Paginação ou “carregar mais” se a lista ficar grande

**Benefício:** Comunidade mais segura e engajada.

---

### 3. **Leaderboard semanal e mensal**  
Hoje só existe ranking “global (todos os tempos)”.

- Leaderboard **semanal**: reset na segunda ou no domingo
- Leaderboard **mensal**: reset no primeiro dia do mês
- Abas ou segmento: Global | Semana | Mês
- Backend: Cloud Function ou regras que considerem `lastChallengeDate` no período

**Benefício:** Quem entra depois ainda pode competir “no mês”; mais motivação.

---

### 4. **Onboarding para novos usuários**  
Quem abre o app pela primeira vez pode não entender o fluxo.

- 2–3 telas: “Um desafio por dia”, “Responda e mantenha sua streak”, “Veja o ranking”
- Skip opcional e “não mostrar de novo” (UserDefaults / Firebase)
- Destacar onde está o desafio do dia e o botão Play

**Benefício:** Menos abandono no primeiro uso.

---

### 5. **Compartilhar resultado do desafio do dia**  
Aumentar divulgação orgânica.

- Botão “Compartilhar” no ResultView (após responder o desafio do dia)
- Texto tipo: “Hoje acertei o desafio do Daily Movie Challenge! 🔥 Streak: X”
- `UIActivityViewController` (share sheet) com texto + opcionalmente link do app

**Benefício:** Crescimento por indicação e reforço da streak como conquista.

---

### 6. **Histórico de streak (calendário ou lista)**  
Mostrar que “não perdi nenhum dia” aumenta compromisso.

- Tela ou seção “Minha streak”
- Calendário (ou lista) com dias jogados (verde) / dias perdidos (cinza) / hoje (destaque)
- Dados: `lastChallengeDate` + lógica de “dias consecutivos” (pode exigir novo campo ou Cloud Function)

**Benefício:** Gamificação mais clara e sensação de progresso.

---

### 7. **Widget (iOS)**  
Streak e “desafio do dia” na tela inicial.

- Widget pequeno: streak + “Desafio do dia disponível”
- Opcional: widget médio com poster do filme do dia
- App Groups para compartilhar UserDefaults/Firebase com o app

**Benefício:** Lembrete diário e mais abertura do app.

---

### 8. **Cache e experiência offline**  
Evitar “Loading…” toda vez e melhorar uso sem rede.

- Cache do desafio do dia (por data) em UserDefaults ou arquivo
- Se já tiver desafio do dia em cache e não houver rede, mostrar cache e avisar “offline”
- Não atualizar streak/estatísticas offline; enviar quando voltar a rede (se quiser, com queue)

**Benefício:** App mais estável em metrô/avião e menos dependente da rede na hora de jogar.

---

### 9. **Acessibilidade e polish**  
Deixar o app mais inclusivo e refinado.

- Labels para VoiceOver em botões e imagens (poster = nome do filme)
- Suporte a Dynamic Type onde fizer sentido
- Haptic feedback ao acertar/errar e ao abrir resultado
- Pequenas animações (ex.: transição para ResultView, contador de streak)

**Benefício:** Mais usuários conseguem usar e a experiência parece mais cuidada.

---

### 10. **Modo prática / infinito**  
Para quem quer jogar além do desafio do dia.

- Botão “Modo Prática” (ex.: na Home ou no ResultView)
- Gera perguntas “extra” em sequência (já existe `getNewMovieChallenge` / extras)
- Não conta para streak nem para leaderboard global; opcional: ranking “prática” ou só estatística local

**Benefício:** Mais tempo de uso e teste de conhecimento sem pressão da streak.

---

### 11. **Analytics básico**  
Entender uso real para decidir próximos passos.

- Eventos: “daily_challenge_started”, “daily_challenge_completed”, “extra_question_played”, “leaderboard_opened”, “notification_settings_opened”
- Firebase Analytics (já tem Firebase) ou evento genérico por tela
- Não coletar dados pessoais; só eventos e telas

**Benefício:** Priorizar o que realmente importa (ex.: onde as pessoas desistem).

---

### 12. **Outras ideias (backlog)**  

- **Dica no desafio:** “Revelar parte do poster” ou uma dica de texto (uma vez por desafio)
- **Tema escuro** explícito (além do sistema)
- **Conquistas adicionais:** ex.: “7 perguntas extras em um dia”, “Primeiro comentário”
- **Notificação “novo líder”** no leaderboard semanal (para quem estava no topo)
- **Testes automatizados:** unitários para streak e regras de negócio; UI tests para fluxo principal

---

## 📋 Ordem sugerida (próximos sprints)

| Ordem | Item                         | Motivo principal                    |
|-------|------------------------------|-------------------------------------|
| 1     | Localização (PT-BR)          | Testadores BR; impacto imediato     |
| 2     | Completar comentários        | Já planejado; segurança e engajamento |
| 3     | Leaderboard semanal/mensal   | Competição recorrente              |
| 4     | Onboarding                   | Reduz abandono no primeiro uso     |
| 5     | Compartilhar resultado       | Crescimento orgânico               |
| 6     | Histórico de streak          | Gamificação                        |
| 7     | Widget                       | Lembrete e abertura do app         |
| 8     | Cache/offline                | Estabilidade e UX                  |
| 9     | Acessibilidade + polish      | Inclusão e qualidade               |
| 10    | Modo prática                 | Mais conteúdo sem mudar regras     |
| 11    | Analytics                    | Decisões baseadas em uso           |

---

## 🚀 Próximo passo

Escolher 1–2 itens para o próximo ciclo (ex.: **PT-BR + comentários** ou **PT-BR + onboarding**) e quebrar em tarefas no código. Posso ajudar a detalhar tarefas e estimativas para o que você escolher.
