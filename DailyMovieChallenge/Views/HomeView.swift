//
//  HomeView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI

// Enum para destinos de navegação
enum NavigationDestination: Hashable {
    case trivia
    case result
}

// Componente separado para o poster usando URLSession diretamente para evitar cancelamentos
struct MoviePosterImageView: View {
    let posterUrl: String?
    let movieTitle: String
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var loadTask: URLSessionDataTask?
    
    var body: some View {
        Group {
            if let image = image {
                // Imagem carregada com sucesso
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 8)
            } else if isLoading {
                ProgressView()
                    .frame(width: 200, height: 300)
            } else if let error = error {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                    Text("Failed to load")
                        .font(.caption)
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        loadImage()
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .frame(width: 200, height: 300)
            } else {
                VStack(spacing: 8) {
                    if let posterUrl = posterUrl, !posterUrl.isEmpty,
                       let url = URL(string: posterUrl), url.scheme != nil, url.host != nil {
                        ProgressView()
                            .onAppear {
                                loadImage()
                            }
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text(posterUrl == nil || posterUrl!.isEmpty ? "No poster available" : "Invalid URL")
                            .font(.caption)
                    }
                }
                .frame(width: 200, height: 300)
                .onAppear {
                    if let posterUrl = posterUrl, !posterUrl.isEmpty,
                       let url = URL(string: posterUrl), url.scheme != nil, url.host != nil {
                        loadImage()
                    }
                }
            }
        }
        .onAppear {
            if let posterUrl = posterUrl, !posterUrl.isEmpty,
               let url = URL(string: posterUrl), url.scheme != nil, url.host != nil {
                if image == nil && !isLoading {
                    loadImage()
                }
            }
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }
    
    private func loadImage() {
        guard let posterUrl = posterUrl,
              !posterUrl.isEmpty,
              let url = URL(string: posterUrl),
              url.scheme != nil,
              url.host != nil else {
            DispatchQueue.main.async {
                self.error = NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            return
        }
        
        if isLoading {
            return
        }
        
        loadTask?.cancel()
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
            self.image = nil
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 30
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        
        loadTask = URLSession.shared.dataTask(with: request) { data, response, err in
            if let nsError = err as NSError?, nsError.code == NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            if let err = err {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = err
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = NSError(domain: "ImageError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                self.isLoading = false
                self.error = nil
            }
        }
        
        loadTask?.resume()
    }
}

struct HomeView: View {
    @EnvironmentObject var challengeViewModel: DailyChallengeViewModel
    @Binding var navigationPath: NavigationPath
    @State private var showLeaderboard = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Daily Movie Challenge")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Streak Indicator com botão de Leaderboard
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Streak: \(challengeViewModel.userStreak)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        showLeaderboard = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.orange)
                            Text("Leaderboard")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                if challengeViewModel.isLoading {
                    ProgressView("Loading challenge...")
                        .padding()
                } else if let challenge = challengeViewModel.challenge {
                    MoviePosterImageView(posterUrl: challenge.posterUrl, movieTitle: challenge.title)
                    
                    // Movie Title
                    Text(challenge.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    // Play Button
                    Button {
                        navigationPath.append(NavigationDestination.trivia)
                    } label: {
                        Text("Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else if let error = challengeViewModel.error {
                    VStack(spacing: 16) {
                        Text("Error loading challenge")
                            .font(.headline)
                        
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await challengeViewModel.loadDailyChallenge()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        Text("No challenge available")
                            .font(.headline)
                        
                        Button("Load Challenge") {
                            Task {
                                await challengeViewModel.loadDailyChallenge()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .onAppear {
            if challengeViewModel.challenge != nil && challengeViewModel.isLoading {
                challengeViewModel.isLoading = false
            }
        }
        .onChange(of: challengeViewModel.challenge) { oldChallenge, newChallenge in
            if newChallenge != nil && challengeViewModel.isLoading {
                challengeViewModel.isLoading = false
            }
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            switch destination {
            case .trivia:
                if let challenge = challengeViewModel.challenge {
                    TriviaView(
                        challenge: challenge,
                        onBackToHome: {
                            // Limpar toda a pilha de navegação
                            navigationPath.removeLast(navigationPath.count)
                        }
                    )
                    .environmentObject(challengeViewModel)
                }
            case .result:
                EmptyView() // Não usado aqui, mas necessário para o enum ser exaustivo
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            NavigationStack {
                LeaderboardView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(navigationPath: .constant(NavigationPath()))
            .environmentObject(DailyChallengeViewModel())
    }
}
