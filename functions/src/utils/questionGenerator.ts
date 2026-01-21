import { TMDBMovie } from './tmdb';

export interface Question {
  question: string;
  options: string[];
  correctAnswer: string;
  questionType: string;
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
    questionType: 'year',
  };
}

/**
 * Gera pergunta sobre o diretor do filme
 */
export function generateDirectorQuestion(movie: TMDBMovie): Question {
  const director = movie.director || 'Unknown';
  const directors = [
    'Christopher Nolan',
    'Steven Spielberg',
    'Quentin Tarantino',
    'Martin Scorsese',
    'Ridley Scott',
    'James Cameron',
    'Peter Jackson',
    'Tim Burton',
    director,
  ];

  const options = new Set<string>([director]);
  while (options.size < 4 && options.size < directors.length) {
    const randomDirector = directors[Math.floor(Math.random() * directors.length)];
    if (randomDirector !== director) {
      options.add(randomDirector);
    }
  }

  return {
    question: `Who directed "${movie.title}"?`,
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer: director,
    questionType: 'director',
  };
}

/**
 * Gera pergunta sobre a nota/rating do filme
 */
export function generateRatingQuestion(movie: TMDBMovie): Question {
  const rating = movie.vote_average.toFixed(1);
  const correctAnswer = rating;

  // Gerar alternativas próximas (±0.5 a ±2.0)
  const options = new Set<string>([correctAnswer]);
  while (options.size < 4) {
    const offset = (Math.random() * 3 - 1.5).toFixed(1); // -1.5 a +1.5
    const wrongRating = (parseFloat(rating) + parseFloat(offset)).toFixed(1);
    if (parseFloat(wrongRating) >= 0 && parseFloat(wrongRating) <= 10 && wrongRating !== correctAnswer) {
      options.add(wrongRating);
    }
  }

  return {
    question: `What is the average rating of "${movie.title}" on TMDB?`,
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer: correctAnswer,
    questionType: 'rating',
  };
}

/**
 * Gera pergunta sobre o gênero principal do filme
 */
export function generateGenreQuestion(movie: TMDBMovie): Question {
  const mainGenre = movie.genres?.[0]?.name || 'Action';
  const genres = [
    'Action',
    'Drama',
    'Comedy',
    'Thriller',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Adventure',
    'Crime',
    'Fantasy',
    mainGenre,
  ];

  const options = new Set<string>([mainGenre]);
  while (options.size < 4 && options.size < genres.length) {
    const randomGenre = genres[Math.floor(Math.random() * genres.length)];
    if (randomGenre !== mainGenre) {
      options.add(randomGenre);
    }
  }

  return {
    question: `What is the main genre of "${movie.title}"?`,
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer: mainGenre,
    questionType: 'genre',
  };
}

/**
 * Gera pergunta sobre a duração (runtime) do filme
 */
export function generateRuntimeQuestion(movie: TMDBMovie): Question {
  const runtime = movie.runtime || 120;
  const correctAnswer = `${runtime} min`;

  // Gerar alternativas próximas (±15 a ±30 minutos)
  const options = new Set<string>([correctAnswer]);
  while (options.size < 4) {
    const offset = Math.floor(Math.random() * 60 - 30); // -30 a +30
    const wrongRuntime = runtime + offset;
    if (wrongRuntime > 60 && wrongRuntime < 240) {
      options.add(`${wrongRuntime} min`);
    }
  }

  return {
    question: `How long is "${movie.title}"?`,
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer: correctAnswer,
    questionType: 'runtime',
  };
}

/**
 * Gera uma pergunta aleatória sobre o filme (excluindo tipos já jogados)
 */
export function generateRandomQuestion(movie: TMDBMovie, excludeTypes: string[]): Question {
  const availableTypes = [
    { type: 'year', generator: generateYearQuestion },
    { type: 'director', generator: generateDirectorQuestion },
    { type: 'rating', generator: generateRatingQuestion },
    { type: 'genre', generator: generateGenreQuestion },
    { type: 'runtime', generator: generateRuntimeQuestion },
  ];

  // Filtrar tipos excluídos
  const validTypes = availableTypes.filter(t => !excludeTypes.includes(t.type));

  if (validTypes.length === 0) {
    // Se todos os tipos foram jogados, usa o primeiro disponível
    return availableTypes[0].generator(movie);
  }

  // Selecionar tipo aleatório dos disponíveis
  const selectedType = validTypes[Math.floor(Math.random() * validTypes.length)];
  return selectedType.generator(movie);
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
    movie.director ? `"${movie.title}" was directed by ${movie.director}.` : null,
    movie.runtime ? `"${movie.title}" has a runtime of ${movie.runtime} minutes.` : null,
    movie.genres && movie.genres.length > 0 ? `"${movie.title}" is a ${movie.genres[0].name} film.` : null,
  ].filter(Boolean) as string[];

  // Selecionar curiosidade aleatória
  return curiosities[Math.floor(Math.random() * curiosities.length)];
}
