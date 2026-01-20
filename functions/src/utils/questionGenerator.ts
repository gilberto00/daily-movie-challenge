import { TMDBMovie } from './tmdb';

export interface Question {
  question: string;
  options: string[];
  correctAnswer: string;
}

/**
 * Gera uma pergunta sobre o ano de lançamento do filme
 */
export function generateYearQuestion(movie: TMDBMovie): Question {
  const year = new Date(movie.release_date).getFullYear();
  const correctAnswer = year.toString();

  // Gerar alternativas incorretas (±2-3 anos)
  const options = new Set<string>([correctAnswer]);
  
  while (options.size < 4) {
    const offset = Math.floor(Math.random() * 6) - 3; // -3 a +2
    if (offset === 0) continue;
    const wrongYear = year + offset;
    if (wrongYear >= 1900 && wrongYear <= new Date().getFullYear() + 1) {
      options.add(wrongYear.toString());
    }
  }

  return {
    question: `In which year was "${movie.title}" released?`,
    options: Array.from(options).sort(() => Math.random() - 0.5), // Embaralhar
    correctAnswer: correctAnswer,
  };
}

/**
 * Gera uma curiosidade baseada em dados reais do filme
 * No MVP, usa informações básicas. Futuramente pode ser expandido.
 */
export function generateCuriosity(movie: TMDBMovie): string {
  const curiosities = [
    `"${movie.title}" was released in ${new Date(movie.release_date).getFullYear()}.`,
    `"${movie.title}" has an average rating of ${movie.vote_average.toFixed(1)}/10 on TMDB.`,
    `"${movie.title}" is a popular film with a score of ${Math.round(movie.popularity)} on TMDB.`,
    `The movie "${movie.title}" is part of the TMDB popular movies collection.`,
  ];

  // Selecionar curiosidade aleatória
  return curiosities[Math.floor(Math.random() * curiosities.length)];
}
