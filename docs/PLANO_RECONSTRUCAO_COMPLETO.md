# 📋 PLANO COMPLETO DE RECONSTRUÇÃO - Daily Movie Challenge

## 🎯 Visão Geral do Projeto

**Daily Movie Challenge** é um app iOS desenvolvido em SwiftUI que oferece desafios diários de trivia sobre filmes. O app utiliza Firebase para autenticação, armazenamento de dados e notificações push.

### Funcionalidades Principais:
- ✅ Desafio diário com perguntas sobre filmes populares
- ✅ Sistema de streak (sequência de acertos)
- ✅ Leaderboard com rankings e badges
- ✅ Sistema completo de comentários (criar, editar, excluir, likes, report)
- ✅ Perguntas extras do mesmo filme (até 5 tipos diferentes)
- ✅ Desafios com novos filmes
- ✅ Notificações push (diárias, streak em risco, badges)
- ✅ Prevenção de perguntas duplicadas na mesma sessão

---

## 🏗️ Arquitetura

### Padrão: MVVM (Model-View-ViewModel)

```
DailyMovieChallenge/
├── Models/              # Domain models (Codable)
├── ViewModels/          # Business logic (ObservableObject)
├── Views/               # SwiftUI views
├── Services/            # Firebase & API services
└── Utils/               # Helpers & extensions
```

### Fluxo de Dados:
```
View → ViewModel → Service → Firebase/API
```

---

## 📦 Dependências e Configurações

### iOS App (Swift Package Manager)

**Firebase iOS SDK:**
- `firebase-ios-sdk` (versão mais recente)
- Módulos necessários:
  - `FirebaseAuth` - Autenticação anônima
  - `FirebaseFirestore` - Banco de dados
  - `FirebaseCore` - Core do Firebase
  - `FirebaseMessaging` - Push notifications

**Como adicionar:**
1. Xcode → File → Add Package Dependencies
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Selecionar os módulos acima

### Cloud Functions (npm)

**Dependências:**
```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.10.0"
  }
}
```

**Node.js:** Versão 22

### Configurações do Projeto

**Deployment Target:** iOS 17.0+

**Bundle Identifier:** Configurar conforme necessário

**Capabilities necessárias:**
- Push Notifications
- Background Modes → Remote notifications

---

## 📊 Modelos de Dados

### 1. `DailyChallenge.swift`
```swift
struct DailyChallenge: Codable, Identifiable, Equatable {
    let id: String  // Date string (YYYY-MM-DD-HH) or custom ID for extras
    let movieId: Int
    let title: String
    let posterUrl: String?
    let question: String
    let options: [String]
    let correctAnswer: String
    let curiosity: String
    let questionType: String?  // 'year', 'director', 'rating', 'genre', 'runtime'
    let isExtra: Bool?
}
```

### 2. `User.swift`
```swift
struct User: Codable {
    let id: String
    let createdAt: Date
    var streak: Int
    var totalChallenges: Int
    var correctAnswers: Int
    var totalAnswers: Int
    var score: Int
    var badges: [String]
    var lastChallengeDate: Date?
    
    var accuracyRate: Double {
        guard totalAnswers > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAnswers) * 100.0
    }
}

struct LeaderboardEntry: Identifiable {
    let id: String
    let username: String
    let score: Int
    let streak: Int
    let accuracy: Double
    let badges: [String]
    let rank: Int
}
```

### 3. `ChallengeResult.swift`
```swift
struct ChallengeResult {
    let isCorrect: Bool
    let correctAnswer: String
    let curiosity: String
}
```

### 4. `Comment.swift`
```swift
struct Comment: Codable, Identifiable, Equatable {
    let id: String
    let challengeId: String
    let userId: String
    let username: String
    let text: String
    let createdAt: Date
    var editedAt: Date?
    var likesCount: Int
    var isLikedByCurrentUser: Bool
    var isReported: Bool
}
```

### 5. `NotificationSettings.swift`
```swift
struct NotificationSettings: Codable {
    var dailyChallenge: Bool = true
    var streakReminder: Bool = true
    var achievements: Bool = true
}
```

---

## 🗄️ Estrutura do Firestore

### Collections:

#### `users/{userId}`
```json
{
  "createdAt": "2026-01-11T10:00:00Z",
  "streak": 0,
  "totalChallenges": 0,
  "correctAnswers": 0,
  "totalAnswers": 0,
  "score": 0,
  "badges": [],
  "lastChallengeDate": null
}
```

#### `dailyChallenges/{date}`
```json
{
  "id": "2026-01-11-09",
  "movieId": 27205,
  "title": "Inception",
  "posterUrl": "https://...",
  "question": "In which year was \"Inception\" released?",
  "options": ["2008", "2010", "2012", "2014"],
  "correctAnswer": "2010",
  "questionType": "year",
  "curiosity": "...",
  "createdAt": "2026-01-11T09:00:00Z"
}
```

#### `comments/{commentId}`
```json
{
  "challengeId": "2026-01-11-09",
  "userId": "abc123",
  "username": "User123",
  "text": "Great movie!",
  "createdAt": "2026-01-11T10:00:00Z",
  "editedAt": null,
  "likesCount": 0,
  "isReported": false
}
```

#### `commentLikes/{likeId}`
```json
{
  "commentId": "comment123",
  "userId": "abc123",
  "createdAt": "2026-01-11T10:00:00Z"
}
```

#### `fcmTokens/{userId}`
```json
{
  "token": "fcm_token_string",
  "updatedAt": "2026-01-11T10:00:00Z"
}
```

#### `notificationSettings/{userId}`
```json
{
  "dailyChallenge": true,
  "streakReminder": true,
  "achievements": true
}
```

### Firestore Rules (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: leitura pública para leaderboard, escrita apenas pelo próprio usuário
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Daily Challenges: leitura pública, escrita apenas por Cloud Functions
    match /dailyChallenges/{date} {
      allow read: if true;
      allow write: if false;
    }

    // Comments: leitura pública, escrita autenticada
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
                       (request.auth.uid == resource.data.userId || 
                        request.resource.data.keys().hasOnly(['text', 'editedAt']) && 
                        request.auth.uid == resource.data.userId);
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Comment Likes: escrita autenticada
    match /commentLikes/{likeId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth != null;
    }
    
    // FCM Tokens: apenas o próprio usuário pode ler/escrever
    match /fcmTokens/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Notification Settings: apenas o próprio usuário pode ler/escrever
    match /notificationSettings/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Firestore Indexes (`firestore.indexes.json`):
```json
{
  "indexes": [
    {
      "collectionGroup": "comments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "challengeId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## 🔧 Serviços

### 1. `AuthService.swift`
**Responsabilidades:**
- Autenticação anônima do Firebase
- Gerenciar usuário atual

**Métodos principais:**
```swift
class AuthService {
    static let shared = AuthService()
    func signInAnonymously() async throws -> String
    func getCurrentUserId() -> String?
    func signOut() throws
}
```

### 2. `FirestoreService.swift`
**Responsabilidades:**
- Operações CRUD no Firestore
- Gerenciar usuários, comentários, estatísticas
- Leaderboard
- FCM tokens e configurações de notificação

**Métodos principais:**
```swift
class FirestoreService {
    static let shared = FirestoreService()
    
    // Users
    func createUser(userId: String) async throws
    func getUser(userId: String) async throws -> User
    func updateUserStreak(userId: String, streak: Int) async throws
    func updateUserStats(userId: String, isCorrect: Bool) async throws
    func checkAndAwardBadges(userId: String) async throws
    
    // Comments
    func fetchComments(challengeId: String) async throws -> [Comment]
    func addComment(challengeId: String, text: String) async throws -> Comment
    func editComment(commentId: String, newText: String) async throws
    func deleteComment(commentId: String) async throws
    func toggleLikeComment(commentId: String) async throws
    func reportComment(commentId: String) async throws
    func getCommentsCount(challengeId: String) async throws -> Int
    
    // Leaderboard
    func fetchLeaderboard(limit: Int) async throws -> [LeaderboardEntry]
    func getUserRank(userId: String) async throws -> Int
    
    // Notifications
    func saveFCMToken(userId: String, token: String) async throws
    func deleteFCMToken(userId: String) async throws
    func saveNotificationSettings(userId: String, settings: NotificationSettings) async throws
    func getNotificationSettings(userId: String) async throws -> NotificationSettings
}
```

### 3. `ChallengeService.swift`
**Responsabilidades:**
- Buscar desafios diários da Cloud Function
- Buscar perguntas extras
- Buscar novos desafios de filmes

**Métodos principais:**
```swift
class ChallengeService {
    static let shared = ChallengeService()
    private let baseURL = "https://us-central1-movie-daily-dev.cloudfunctions.net"
    
    func fetchDailyChallenge() async throws -> DailyChallenge
    func fetchExtraQuestion(movieId: Int, excludeTypes: [String]) async throws -> DailyChallenge
    func fetchNewMovieChallenge() async throws -> DailyChallenge
}
```

### 4. `NotificationService.swift`
**Responsabilidades:**
- Solicitar permissão de notificações
- Gerenciar tokens FCM
- Configurações de notificações

**Métodos principais:**
```swift
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    @Published var isAuthorized: Bool = false
    @Published var fcmToken: String?
    
    func requestAuthorization() async -> Bool
    func setupFCM()
    func getNotificationSettings() async throws -> NotificationSettings
    func updateNotificationSettings(_ settings: NotificationSettings) async throws
}
```

---

## 📱 ViewModels

### 1. `AuthViewModel.swift`
**Responsabilidades:**
- Gerenciar estado de autenticação
- Inicializar autenticação anônima

**Propriedades:**
```swift
@Published var isAuthenticated: Bool = false
@Published var isLoading: Bool = false
@Published var error: Error?
```

### 2. `DailyChallengeViewModel.swift`
**Responsabilidades:**
- Carregar desafio diário
- Gerenciar streak do usuário
- Submeter respostas
- Carregar perguntas extras e novos filmes
- Rastrear perguntas já jogadas (prevenir duplicatas)

**Propriedades:**
```swift
@Published var challenge: DailyChallenge?
@Published var isLoading: Bool = false
@Published var error: Error?
@Published var userStreak: Int = 0

// Rastreamento de perguntas
private var playedQuestionIds: Set<String> = []
private var playedQuestionTypesByMovie: [Int: Set<String>] = [:]
private var playedQuestionTextsByMovie: [Int: Set<String>] = [:]
```

**Métodos principais:**
```swift
func loadDailyChallenge() async
func submitAnswer(_ answer: String) async -> ChallengeResult
func loadExtraQuestion(movieId: Int, excludeTypes: [String]) async
func loadNewMovieChallenge() async
func areAllQuestionsPlayed(for movieId: Int) -> Bool
func getPlayedQuestionTypes(for movieId: Int) -> [String]
func resetQuestionTracking()
```

### 3. `TriviaGameViewModel.swift`
**Responsabilidades:**
- Gerenciar seleção de resposta
- Estado do jogo

**Propriedades:**
```swift
@Published var selectedAnswer: String?
@Published var isSubmitted: Bool = false
```

### 4. `CommentsViewModel.swift`
**Responsabilidades:**
- Carregar comentários
- Criar, editar, excluir comentários
- Gerenciar likes
- Reportar comentários

**Propriedades:**
```swift
@Published var comments: [Comment] = []
@Published var isLoading: Bool = false
@Published var error: Error?
```

### 5. `LeaderboardViewModel.swift`
**Responsabilidades:**
- Carregar leaderboard
- Obter posição do usuário

**Propriedades:**
```swift
@Published var entries: [LeaderboardEntry] = []
@Published var userEntry: LeaderboardEntry?
@Published var userRank: Int?
@Published var isLoading: Bool = false
```

---

## 🎨 Views

### 1. `ContentView.swift` (Root)
**Responsabilidades:**
- NavigationStack principal
- Gerenciar autenticação
- Roteamento entre views

**Estrutura:**
```swift
NavigationStack {
    if authViewModel.isAuthenticated {
        HomeView()
            .environmentObject(authViewModel)
            .environmentObject(challengeViewModel)
    } else {
        ProgressView("Loading...")
    }
}
```

### 2. `HomeView.swift`
**Responsabilidades:**
- Exibir desafio diário
- Mostrar poster do filme
- Botão "Play" para iniciar jogo
- Botão "Leaderboard"
- Loading state

**Componentes:**
- `MoviePosterImageView` - Carregamento customizado de imagens
- Indicador de streak
- Navegação para TriviaView e LeaderboardView

### 3. `TriviaView.swift`
**Responsabilidades:**
- Exibir pergunta
- Mostrar opções de resposta
- Botão "Submit"
- Layout adaptativo (grid para opções curtas, lista para longas)
- Safe area handling para botão Submit

**Características:**
- Layout responsivo que evita sobreposição com home indicator
- Usa `.safeAreaInset(edge: .bottom)` para botão fixo

### 4. `ResultView.swift`
**Responsabilidades:**
- Exibir resultado (correto/incorreto)
- Mostrar resposta correta
- Exibir curiosidade
- Botão "View Comments"
- Botão "More Questions (Same Movie)" - desabilitado quando todas as 5 perguntas foram jogadas
- Botão "New Movie Challenge"
- Botão "Back to Home" - navegação direta

**Características:**
- Animações de entrada
- Sheet para comentários
- Navegação direta para Home (não volta página por página)

### 5. `CommentsView.swift`
**Responsabilidades:**
- Lista de comentários
- Campo de texto para novo comentário
- Edição e exclusão de comentários próprios
- Likes e reports

**Componentes:**
- `CommentRowView` - Linha individual de comentário
- Pull-to-refresh

### 6. `LeaderboardView.swift`
**Responsabilidades:**
- Exibir top players
- Mostrar posição do usuário
- Exibir badges e estatísticas

**Componentes:**
- `LeaderboardRowView` - Linha individual do ranking
- `BadgeView` - Exibição de badges
- Pull-to-refresh

### 7. `MoviePosterImageView.swift`
**Responsabilidades:**
- Carregamento customizado de imagens usando URLSession
- Retry logic
- Estados de loading e error

**Características:**
- Resolve problema de cancelamento do AsyncImage (NSURLErrorDomain -999)
- Cache de imagens

---

## ☁️ Cloud Functions

### Estrutura do Projeto:
```
functions/
├── src/
│   ├── index.ts
│   └── utils/
│       ├── tmdb.ts
│       └── questionGenerator.ts
├── package.json
└── tsconfig.json
```

### 1. `getDailyChallenge` (HTTP Endpoint)
**Endpoint:** `GET /getDailyChallenge?date=YYYY-MM-DD-HH`

**Lógica:**
1. Verificar se challenge existe no Firestore
2. Se existe, retornar
3. Se não existe:
   - Buscar filme popular do TMDB
   - Gerar pergunta do tipo "year"
   - Gerar curiosidade
   - Salvar no Firestore
   - Retornar JSON

### 2. `getExtraQuestion` (HTTP Endpoint)
**Endpoint:** `GET /getExtraQuestion?movieId=123&excludeTypes=year,director`

**Lógica:**
1. Buscar detalhes do filme no TMDB
2. Gerar pergunta aleatória excluindo tipos já jogados
3. Gerar ID único com timestamp e random string
4. Retornar pergunta

**Tipos de perguntas disponíveis:**
- `year` - Ano de lançamento
- `director` - Diretor
- `rating` - Nota no TMDB
- `genre` - Gênero principal
- `runtime` - Duração

### 3. `getNewMovieChallenge` (HTTP Endpoint)
**Endpoint:** `GET /getNewMovieChallenge`

**Lógica:**
1. Buscar novo filme popular do TMDB
2. Gerar pergunta do tipo "year"
3. Retornar desafio

### 4. `sendDailyChallengeNotification` (Scheduled Function)
**Schedule:** `0 9 * * *` (9h todo dia, horário de São Paulo)

**Lógica:**
1. Buscar todos os tokens FCM
2. Verificar configurações de notificação
3. Buscar desafio do dia
4. Enviar notificação para usuários com `dailyChallenge: true`

### 5. `sendStreakReminderNotification` (Scheduled Function)
**Schedule:** `0 20 * * *` (20h todo dia, horário de São Paulo)

**Lógica:**
1. Buscar usuários com streak > 0
2. Verificar se completaram desafio hoje
3. Enviar notificação para quem não completou e tem `streakReminder: true`

### 6. `onBadgeAwarded` (Firestore Trigger)
**Trigger:** `users/{userId}` onUpdate

**Lógica:**
1. Detectar novos badges adicionados
2. Verificar configurações de notificação
3. Enviar notificação para usuários com `achievements: true`

### Utils:

#### `tmdb.ts`
- `fetchPopularMovie()` - Busca filme popular aleatório
- `fetchMovieDetails(movieId)` - Busca detalhes de um filme
- `getPosterUrl(posterPath)` - Gera URL do poster

#### `questionGenerator.ts`
- `generateYearQuestion(movie)` - Pergunta sobre ano
- `generateDirectorQuestion(movie)` - Pergunta sobre diretor
- `generateRatingQuestion(movie)` - Pergunta sobre nota
- `generateGenreQuestion(movie)` - Pergunta sobre gênero
- `generateRuntimeQuestion(movie)` - Pergunta sobre duração
- `generateRandomQuestion(movie, excludeTypes)` - Pergunta aleatória
- `generateCuriosity(movie)` - Gera curiosidade

---

## 🚀 Passo a Passo de Implementação

### Fase 1: Setup Inicial

1. **Criar projeto Xcode**
   - Template: iOS App
   - Interface: SwiftUI
   - Language: Swift
   - Deployment Target: iOS 17.0+

2. **Configurar Firebase**
   - Criar projeto no Firebase Console
   - Adicionar app iOS
   - Baixar `GoogleService-Info.plist`
   - Adicionar ao projeto Xcode

3. **Adicionar Firebase SDK**
   - File → Add Package Dependencies
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Selecionar: FirebaseAuth, FirebaseFirestore, FirebaseCore, FirebaseMessaging

4. **Criar estrutura de pastas**
   ```
   DailyMovieChallenge/
   ├── Models/
   ├── ViewModels/
   ├── Views/
   ├── Services/
   └── Utils/
   ```

5. **Configurar Capabilities**
   - Push Notifications
   - Background Modes → Remote notifications

### Fase 2: Models

1. Criar `DailyChallenge.swift`
2. Criar `User.swift`
3. Criar `ChallengeResult.swift`
4. Criar `Comment.swift`
5. Criar `NotificationSettings.swift`

### Fase 3: Services

1. Criar `AuthService.swift`
   - Implementar `signInAnonymously()`
   - Implementar `getCurrentUserId()`

2. Criar `FirestoreService.swift`
   - Implementar métodos de usuário
   - Implementar métodos de comentários
   - Implementar métodos de leaderboard
   - Implementar métodos de notificações

3. Criar `ChallengeService.swift`
   - Implementar `fetchDailyChallenge()`
   - Implementar `fetchExtraQuestion()`
   - Implementar `fetchNewMovieChallenge()`

4. Criar `NotificationService.swift`
   - Implementar `requestAuthorization()`
   - Implementar `setupFCM()`
   - Implementar `MessagingDelegate`

### Fase 4: ViewModels

1. Criar `AuthViewModel.swift`
2. Criar `DailyChallengeViewModel.swift`
   - Implementar rastreamento de perguntas
   - Implementar prevenção de duplicatas
3. Criar `TriviaGameViewModel.swift`
4. Criar `CommentsViewModel.swift`
5. Criar `LeaderboardViewModel.swift`

### Fase 5: Views

1. Criar `MoviePosterImageView.swift`
2. Criar `HomeView.swift`
3. Criar `TriviaView.swift`
   - Implementar layout adaptativo
   - Implementar safe area handling
4. Criar `ResultView.swift`
   - Implementar navegação direta para Home
   - Implementar bloqueio de botão quando todas as perguntas foram jogadas
5. Criar `CommentsView.swift`
6. Criar `LeaderboardView.swift`
7. Criar `ContentView.swift`

### Fase 6: App Entry Point

1. Atualizar `DailyMovieChallengeApp.swift`
   - Configurar Firebase
   - Configurar NotificationService
   - Implementar `UNUserNotificationCenterDelegate`
   - Implementar `MessagingDelegate`

### Fase 7: Cloud Functions

1. **Inicializar projeto Functions**
   ```bash
   cd functions
   npm install
   ```

2. **Criar estrutura:**
   - `src/index.ts`
   - `src/utils/tmdb.ts`
   - `src/utils/questionGenerator.ts`

3. **Implementar funções:**
   - `getDailyChallenge`
   - `getExtraQuestion`
   - `getNewMovieChallenge`
   - `sendDailyChallengeNotification`
   - `sendStreakReminderNotification`
   - `onBadgeAwarded`

4. **Configurar variáveis de ambiente:**
   ```bash
   firebase functions:config:set tmdb.api_key="YOUR_TMDB_API_KEY"
   ```

5. **Deploy:**
   ```bash
   npm run build
   firebase deploy --only functions
   ```

### Fase 8: Firestore Setup

1. **Deploy Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Deploy Indexes:**
   ```bash
   firebase deploy --only firestore:indexes
   ```

### Fase 9: Push Notifications Setup

1. **Apple Developer Portal:**
   - Criar APNs Auth Key (.p8) ou Certificate (.p12)
   - Ver documentação: `COMO_OBTER_CERTIFICADO_APNS.md`

2. **Firebase Console:**
   - Upload do certificado APNs
   - Configurar App ID

3. **Xcode:**
   - Verificar Push Notifications capability
   - Verificar Background Modes

---

## 🔑 Configurações Importantes

### Firebase Configuration

**firebase.json:**
```json
{
  "functions": {
    "source": "functions",
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run build"
    ]
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

### Info.plist

**Configurações necessárias:**
- Bundle Identifier
- Display Name
- Permissões de notificações (se necessário)

### Entitlements

**DailyMovieChallenge.entitlements:**
- Push Notifications: `aps-environment: development` ou `production`

---

## 🐛 Problemas Conhecidos e Soluções

### 1. AsyncImage Cancellation (NSURLErrorDomain -999)
**Solução:** Usar `MoviePosterImageView` com `URLSession` customizado

### 2. Perguntas Duplicadas
**Solução:** Sistema de rastreamento por ID, tipo e texto completo

### 3. Botão Submit sobre Home Indicator
**Solução:** Usar `.safeAreaInset(edge: .bottom)` ou `GeometryReader` com padding baseado em `safeAreaInsets`

### 4. Navegação Lenta
**Solução:** Navegação direta usando `NavigationPath` e `onBackToHome()`

### 5. Firestore Permissions
**Solução:** Verificar e deployar regras corretas

---

## 📝 Checklist de Implementação

### iOS App
- [ ] Projeto Xcode criado
- [ ] Firebase SDK adicionado
- [ ] GoogleService-Info.plist configurado
- [ ] Capabilities configuradas
- [ ] Models criados
- [ ] Services implementados
- [ ] ViewModels implementados
- [ ] Views implementadas
- [ ] App entry point configurado
- [ ] Testes básicos realizados

### Cloud Functions
- [ ] Projeto Functions inicializado
- [ ] Dependências instaladas
- [ ] Funções implementadas
- [ ] TMDB API key configurada
- [ ] Deploy realizado
- [ ] Testes de endpoints realizados

### Firestore
- [ ] Rules criadas
- [ ] Indexes criados
- [ ] Deploy realizado
- [ ] Testes de permissões realizados

### Push Notifications
- [ ] APNs certificado obtido
- [ ] Certificado uploadado no Firebase
- [ ] NotificationService implementado
- [ ] Cloud Functions de notificação deployadas
- [ ] Testes de notificações realizados

---

## 📚 Documentação Adicional

- `SETUP_PUSH_NOTIFICATIONS.md` - Setup detalhado de push notifications
- `COMO_OBTER_CERTIFICADO_APNS.md` - Como obter certificado APNs
- `SPRINT_2.md` - Detalhes da Sprint 2
- `ITEM_7_RESUMO_IMPLEMENTACAO.md` - Resumo da implementação de push notifications

---

## 🎯 Features Implementadas

### Sprint 1 (MVP)
- ✅ Autenticação anônima
- ✅ Desafio diário
- ✅ Sistema de streak
- ✅ Trivia game básico

### Sprint 2
- ✅ Sistema completo de comentários
- ✅ Leaderboard com badges
- ✅ Perguntas extras (até 5 por filme)
- ✅ Prevenção de perguntas duplicadas
- ✅ Push notifications
- ✅ Navegação otimizada

---

## 🔄 Próximos Passos (Sprint 3+)

- Perfis de usuário
- Social features (seguir usuários)
- Mais tipos de perguntas
- Modo multiplayer
- Histórico de desafios
- Estatísticas detalhadas

---

## 📞 Suporte

Para dúvidas ou problemas durante a reconstrução, consulte:
1. Este documento
2. Código fonte comentado
3. Documentação do Firebase
4. Documentação do SwiftUI

---

**Última atualização:** 2026-01-20
**Versão do App:** 1.0.0
**Versão do Documento:** 1.0.0
