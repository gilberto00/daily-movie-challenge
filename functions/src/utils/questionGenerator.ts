import { TMDBMovie } from './tmdb';
import { type Lang, getQuestionTemplate, getUnknownDirector, translateGenre, getCuriosityTemplates } from './translations';

export interface Question {
  question: string;
  options: string[];
  correctAnswer: string;
  questionType: string;
}

function defaultLang(lang?: Lang): Lang {
  return lang ?? 'en';
}

/**
 * Gera uma pergunta sobre o ano de lançamento do filme (no idioma solicitado)
 */
export function generateYearQuestion(movie: TMDBMovie, lang?: Lang): Question {
  const year = new Date(movie.release_date).getFullYear();
  const correctAnswer = year.toString();

  const options = new Set<string>([correctAnswer]);
  while (options.size < 4) {
    const offset = Math.floor(Math.random() * 6) - 3;
    if (offset === 0) continue;
    const wrongYear = year + offset;
    if (wrongYear >= 1900 && wrongYear <= new Date().getFullYear() + 1) {
      options.add(wrongYear.toString());
    }
  }

  const l = defaultLang(lang);
  return {
    question: getQuestionTemplate('year', l, movie.title),
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer,
    questionType: 'year',
  };
}

/**
 * Gera pergunta sobre o diretor do filme
 */
export function generateDirectorQuestion(movie: TMDBMovie, lang?: Lang): Question {
  const l = defaultLang(lang);
  const director = movie.director || getUnknownDirector(l);
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
    question: getQuestionTemplate('director', l, movie.title),
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer: director,
    questionType: 'director',
  };
}

/**
 * Gera pergunta sobre a nota/rating do filme
 */
export function generateRatingQuestion(movie: TMDBMovie, lang?: Lang): Question {
  const rating = movie.vote_average.toFixed(1);
  const correctAnswer = rating;

  const options = new Set<string>([correctAnswer]);
  while (options.size < 4) {
    const offset = (Math.random() * 3 - 1.5).toFixed(1);
    const wrongRating = (parseFloat(rating) + parseFloat(offset)).toFixed(1);
    if (parseFloat(wrongRating) >= 0 && parseFloat(wrongRating) <= 10 && wrongRating !== correctAnswer) {
      options.add(wrongRating);
    }
  }

  const l = defaultLang(lang);
  return {
    question: getQuestionTemplate('rating', l, movie.title),
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer,
    questionType: 'rating',
  };
}

/**
 * Gera pergunta sobre o gênero principal do filme (opções traduzidas quando lang não é en)
 */
export function generateGenreQuestion(movie: TMDBMovie, lang?: Lang): Question {
  const l = defaultLang(lang);
  const mainGenreEn = movie.genres?.[0]?.name || 'Action';
  const genresEn = [
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
    mainGenreEn,
  ];

  const mainGenre = translateGenre(mainGenreEn, l);
  const optionsEn = new Set<string>([mainGenreEn]);
  while (optionsEn.size < 4 && optionsEn.size < genresEn.length) {
    const randomGenre = genresEn[Math.floor(Math.random() * genresEn.length)];
    if (randomGenre !== mainGenreEn) {
      optionsEn.add(randomGenre);
    }
  }
  const options = Array.from(optionsEn).map((g) => translateGenre(g, l));

  return {
    question: getQuestionTemplate('genre', l, movie.title),
    options: options.sort(() => Math.random() - 0.5),
    correctAnswer: mainGenre,
    questionType: 'genre',
  };
}

/**
 * Gera pergunta sobre a duração (runtime) do filme
 */
export function generateRuntimeQuestion(movie: TMDBMovie, lang?: Lang): Question {
  const runtime = movie.runtime || 120;
  const correctAnswer = `${runtime} min`;

  const options = new Set<string>([correctAnswer]);
  while (options.size < 4) {
    const offset = Math.floor(Math.random() * 60 - 30);
    const wrongRuntime = runtime + offset;
    if (wrongRuntime > 60 && wrongRuntime < 240) {
      options.add(`${wrongRuntime} min`);
    }
  }

  const l = defaultLang(lang);
  return {
    question: getQuestionTemplate('runtime', l, movie.title),
    options: Array.from(options).sort(() => Math.random() - 0.5),
    correctAnswer,
    questionType: 'runtime',
  };
}

/**
 * Gera uma pergunta aleatória sobre o filme (excluindo tipos já jogados)
 */
export function generateRandomQuestion(movie: TMDBMovie, excludeTypes: string[], lang?: Lang): Question {
  const availableTypes = [
    { type: 'year', generator: (m: TMDBMovie) => generateYearQuestion(m, lang) },
    { type: 'director', generator: (m: TMDBMovie) => generateDirectorQuestion(m, lang) },
    { type: 'rating', generator: (m: TMDBMovie) => generateRatingQuestion(m, lang) },
    { type: 'genre', generator: (m: TMDBMovie) => generateGenreQuestion(m, lang) },
    { type: 'runtime', generator: (m: TMDBMovie) => generateRuntimeQuestion(m, lang) },
  ];

  const validTypes = availableTypes.filter((t) => !excludeTypes.includes(t.type));

  if (validTypes.length === 0) {
    return availableTypes[0].generator(movie);
  }

  const selectedType = validTypes[Math.floor(Math.random() * validTypes.length)];
  return selectedType.generator(movie);
}

/**
 * Gera uma pergunta baseada em um tipo específico (mantém o mesmo tipo entre idiomas).
 */
export function generateQuestionByType(questionType: string, movie: TMDBMovie, lang?: Lang): Question {
  switch (questionType) {
    case 'director':
      return generateDirectorQuestion(movie, lang);
    case 'rating':
      return generateRatingQuestion(movie, lang);
    case 'genre':
      return generateGenreQuestion(movie, lang);
    case 'runtime':
      return generateRuntimeQuestion(movie, lang);
    case 'year':
    default:
      return generateYearQuestion(movie, lang);
  }
}

/**
 * Gera uma curiosidade no idioma solicitado
 */
export function generateCuriosity(movie: TMDBMovie, lang?: Lang): string {
  const l = defaultLang(lang);
  const templates = getCuriosityTemplates(l);
  const valid = templates.map((fn) => fn(movie)).filter((s): s is string => s != null);
  return valid[Math.floor(Math.random() * valid.length)] ?? templates[0](movie) ?? '';
}
