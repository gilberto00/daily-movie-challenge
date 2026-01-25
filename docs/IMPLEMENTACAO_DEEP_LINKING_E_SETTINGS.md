# 🔗 Implementação: Deep Linking e Configurações de Notificações

## 📋 Resumo

Este documento descreve a implementação dos itens **7.4 (Deep Linking)** e **7.5 (Configurações de Notificações)** do Sprint 2, que foram implementados enquanto aguardamos o processamento do Apple Developer Membership.

---

## ✅ Item 7.4: Deep Linking

### Arquivos Criados/Modificados

1. **`DeepLinkService.swift`** (Novo)
   - Serviço centralizado para processar deep links
   - Suporta URL schemes customizados (`dailymoviechallenge://`)
   - Suporta Universal Links (futuro)
   - Processa notificações push para extrair destinos

2. **`Info.plist`**
   - Adicionado `CFBundleURLTypes` com scheme `dailymoviechallenge`
   - Permite que o app seja aberto via URLs customizadas

3. **`DailyMovieChallengeApp.swift`**
   - Integrado `DeepLinkService` como `@StateObject`
   - Adicionado `.onOpenURL` para capturar deep links
   - Implementado `handleDeepLink()` para processar URLs e navegar

4. **`ContentView.swift`**
   - Atualizado para receber `navigationPath` como `@Binding`
   - Integrado com `DeepLinkService` via `@EnvironmentObject`

5. **`HomeView.swift`**
   - Atualizado `NavigationDestination` enum para incluir `.leaderboard` e `.settings`
   - Adicionado suporte para navegação programática via deep links

### Funcionalidades Implementadas

- ✅ URL Scheme: `dailymoviechallenge://home`
- ✅ URL Scheme: `dailymoviechallenge://trivia`
- ✅ URL Scheme: `dailymoviechallenge://leaderboard`
- ✅ URL Scheme: `dailymoviechallenge://settings`
- ✅ Suporte a query parameters: `dailymoviechallenge://trivia?movieId=123`
- ✅ Processamento de notificações push para deep linking
- ✅ Navegação automática baseada em deep links

### Exemplos de Uso

```swift
// Abrir Home
dailymoviechallenge://home

// Abrir Trivia
dailymoviechallenge://trivia

// Abrir Trivia com movieId específico
dailymoviechallenge://trivia?movieId=27205

// Abrir Leaderboard
dailymoviechallenge://leaderboard

// Abrir Settings
dailymoviechallenge://settings
```

### Como Testar

1. **Via Terminal (Simulador iOS):**
   ```bash
   xcrun simctl openurl booted "dailymoviechallenge://home"
   xcrun simctl openurl booted "dailymoviechallenge://leaderboard"
   xcrun simctl openurl booted "dailymoviechallenge://settings"
   ```

2. **Via Safari (Dispositivo Real):**
   - Digite na barra de endereços: `dailymoviechallenge://home`
   - O app será aberto automaticamente

3. **Via Notificações Push:**
   - Quando uma notificação for recebida, o payload pode incluir `destination` e `movieId`
   - O app navegará automaticamente para o destino especificado

---

## ✅ Item 7.5: Configurações de Notificações

### Arquivos Criados/Modificados

1. **`NotificationSettingsView.swift`** (Novo)
   - Tela completa para gerenciar preferências de notificações
   - Toggles para cada tipo de notificação:
     - Daily Challenge Notifications
     - Streak Reminder
     - Achievements & Badges
     - Comment Notifications
   - Exibe status de autorização de notificações
   - Exibe FCM token (para debug)
   - Botão para habilitar notificações se desabilitadas

2. **`HomeView.swift`**
   - Adicionado botão de Settings (ícone de sino) na barra de streak
   - Abre `NotificationSettingsView` como sheet
   - Integrado com `NavigationDestination.settings` para deep linking

3. **`NotificationService.swift`** (Já existente)
   - Métodos `getNotificationSettings()` e `updateNotificationSettings()` já implementados
   - Integração com Firestore para persistir preferências

### Funcionalidades Implementadas

- ✅ Tela de configurações completa
- ✅ Toggles para cada tipo de notificação
- ✅ Salvamento automático ao alterar preferências
- ✅ Exibição de status de autorização
- ✅ Botão para habilitar notificações
- ✅ Exibição de FCM token (debug)
- ✅ Integração com Firestore
- ✅ Acesso via deep link: `dailymoviechallenge://settings`
- ✅ Acesso via botão na HomeView

### Estrutura de Dados

As preferências são salvas no Firestore em:
```
notificationSettings/{userId}
{
  dailyChallenge: boolean,
  streakReminder: boolean,
  achievements: boolean,
  comments: boolean
}
```

### Como Acessar

1. **Via HomeView:**
   - Toque no ícone de sino (🔔) ao lado do botão "Leaderboard"

2. **Via Deep Link:**
   - `dailymoviechallenge://settings`

3. **Via Navegação Programática:**
   - `navigationPath.append(NavigationDestination.settings)`

---

## 🔧 Integração com Notificações Push

### Payload de Notificação

Quando uma notificação push é enviada, o payload pode incluir:

```json
{
  "aps": {
    "alert": {
      "title": "Novo desafio disponível!",
      "body": "Teste seus conhecimentos sobre filmes 🎬"
    },
    "sound": "default"
  },
  "destination": "home",
  "movieId": 27205
}
```

O `DeepLinkService` processa automaticamente e navega para o destino correto.

---

## 📝 Próximos Passos

### Após Receber Apple Developer Membership:

1. **Configurar APNs:**
   - Fazer upload do certificado `.p8` ou `.p12` no Firebase Console
   - Testar notificações push em dispositivo real

2. **Universal Links (Opcional):**
   - Configurar domínio associado
   - Criar `apple-app-site-association` file
   - Atualizar `DeepLinkService` para suportar Universal Links

3. **Testes de Deep Linking:**
   - Testar deep links em dispositivo real
   - Validar navegação a partir de notificações push
   - Verificar comportamento quando app está em background/foreground

---

## 🐛 Troubleshooting

### Deep Links não funcionam:

1. Verifique se o `Info.plist` contém `CFBundleURLTypes`
2. Verifique se o scheme está correto: `dailymoviechallenge`
3. No simulador, use `xcrun simctl openurl`
4. No dispositivo real, teste via Safari

### Configurações não salvam:

1. Verifique se o usuário está autenticado
2. Verifique as regras do Firestore para `notificationSettings`
3. Verifique os logs do console para erros

### Notificações não aparecem:

1. Verifique se as permissões foram concedidas
2. Verifique se o FCM token está sendo salvo no Firestore
3. Aguarde o processamento do Apple Developer Membership para testar em dispositivo real

---

## ✅ Checklist de Implementação

- [x] DeepLinkService criado
- [x] URL schemes configurados no Info.plist
- [x] Integração com DailyMovieChallengeApp
- [x] Navegação programática implementada
- [x] NotificationSettingsView criada
- [x] Integração com Firestore
- [x] Botão de acesso na HomeView
- [x] Deep linking para settings
- [x] Processamento de notificações push
- [x] Documentação completa

---

**Data de Implementação:** 24 de Janeiro de 2026  
**Status:** ✅ Completo (aguardando Apple Developer Membership para testes em dispositivo real)
