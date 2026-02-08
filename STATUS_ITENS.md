# Status dos Itens (Implementados e Planejados)

Atualizado em: 2026-02-03

## Implementados

### Item 1 — Localização (PT-BR e fr-CA)
- UI localizada com `Localizable.strings` nas telas principais.

### Item 2 — Nomes no leaderboard
- Campo `displayName`/nome no Firestore.
- Exibição no ranking e edição pelo usuário.

### Item 3 — Botão compartilhar
- Share sheet do iOS com texto localizável.
- Botão “Compartilhar no Facebook” (share web).
- Subject em e-mail configurado.

### Item 4 — Propor desafios para outros jogadores
- Botão “Desafiar amigos” com texto localizável.
- Deep link para desafio do dia: `dailymoviechallenge://challenge/today`.

### Item 5 — Tela de resultados (inspirada no LinkedIn Games)
- Bloco de ações rápidas (copiar resultado + shares).
- Streak tracker simples (7 dias).
- Toggle de lembrete do desafio de amanhã.
- Confete com profundidade (camadas).

### Ajustes adicionais no backend
- Primeira pergunta do desafio diário agora é aleatória.
- Notificação diária não é enviada para quem já completou o desafio do dia.
- Streak reminder usa data no fuso de Toronto.

## Planejados

### Item 6 — Monetização inicial (ads leves, baixo atrito)
- Anúncios leves em telas secundárias (ex.: resultado/settings).
- Rewarded ad opcional com benefício leve.
- Sem paywall no MVP.
### Próximos candidatos (após item 6)
- Mini leaderboard na tela de resultado.
- Social proof (“X pessoas jogaram hoje”).
