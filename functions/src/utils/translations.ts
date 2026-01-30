/**
 * Traduções para perguntas e curiosidades (en, pt-BR, fr-CA).
 * Usar idioma do sistema no app e parâmetro lang nas requisições.
 */
export type Lang = 'en' | 'pt-BR' | 'fr-CA';

const templates = {
  year: {
    en: (title: string) => `In which year was "${title}" released?`,
    'pt-BR': (title: string) => `Em que ano "${title}" foi lançado?`,
    'fr-CA': (title: string) => `En quelle année « ${title} » a-t-il été sorti?`,
  },
  director: {
    en: (title: string) => `Who directed "${title}"?`,
    'pt-BR': (title: string) => `Quem dirigiu "${title}"?`,
    'fr-CA': (title: string) => `Qui a réalisé « ${title} »?`,
  },
  rating: {
    en: (title: string) => `What is the average rating of "${title}" on TMDB?`,
    'pt-BR': (title: string) => `Qual é a nota média de "${title}" no TMDB?`,
    'fr-CA': (title: string) => `Quelle est la note moyenne de « ${title} » sur TMDB?`,
  },
  genre: {
    en: (title: string) => `What is the main genre of "${title}"?`,
    'pt-BR': (title: string) => `Qual é o gênero principal de "${title}"?`,
    'fr-CA': (title: string) => `Quel est le genre principal de « ${title} »?`,
  },
  runtime: {
    en: (title: string) => `How long is "${title}"?`,
    'pt-BR': (title: string) => `Qual é a duração de "${title}"?`,
    'fr-CA': (title: string) => `Quelle est la durée de « ${title} »?`,
  },
} as const;

const unknownDirector: Record<Lang, string> = {
  en: 'Unknown',
  'pt-BR': 'Desconhecido',
  'fr-CA': 'Inconnu',
};

const genreNames: Record<string, Record<Lang, string>> = {
  Action: { en: 'Action', 'pt-BR': 'Ação', 'fr-CA': 'Action' },
  Drama: { en: 'Drama', 'pt-BR': 'Drama', 'fr-CA': 'Drame' },
  Comedy: { en: 'Comedy', 'pt-BR': 'Comédia', 'fr-CA': 'Comédie' },
  Thriller: { en: 'Thriller', 'pt-BR': 'Thriller', 'fr-CA': 'Thriller' },
  Horror: { en: 'Horror', 'pt-BR': 'Terror', 'fr-CA': 'Horreur' },
  Romance: { en: 'Romance', 'pt-BR': 'Romance', 'fr-CA': 'Romance' },
  'Sci-Fi': { en: 'Sci-Fi', 'pt-BR': 'Ficção científica', 'fr-CA': 'Science-fiction' },
  Adventure: { en: 'Adventure', 'pt-BR': 'Aventura', 'fr-CA': 'Aventure' },
  Crime: { en: 'Crime', 'pt-BR': 'Crime', 'fr-CA': 'Crime' },
  Fantasy: { en: 'Fantasy', 'pt-BR': 'Fantasia', 'fr-CA': 'Fantaisie' },
};

export function getQuestionTemplate(type: keyof typeof templates, lang: Lang, title: string): string {
  const t = templates[type][lang] ?? templates[type].en;
  return t(title);
}

export function getUnknownDirector(lang: Lang): string {
  return unknownDirector[lang];
}

export function translateGenre(genreEn: string, lang: Lang): string {
  if (lang === 'en') return genreEn;
  const entry = genreNames[genreEn];
  return entry?.[lang] ?? genreEn;
}

/** Curiosidades: array de funções (movie) => string por idioma */
export function getCuriosityTemplates(lang: Lang): Array<(m: { title: string; release_date: string; vote_average: number; popularity: number; director?: string; runtime?: number; genres?: { name: string }[] }) => string | null> {
  const title = (m: { title: string }) => m.title;
  const year = (m: { release_date: string }) => new Date(m.release_date).getFullYear();
  const rating = (m: { vote_average: number }) => m.vote_average.toFixed(1);
  const pop = (m: { popularity: number }) => Math.round(m.popularity);
  const dir = (m: { director?: string }) => m.director;
  const run = (m: { runtime?: number }) => m.runtime;
  const genre = (m: { genres?: { name: string }[] }) => m.genres?.[0]?.name;

  if (lang === 'pt-BR') {
    return [
      (m) => `"${title(m)}" foi lançado em ${year(m)}.`,
      (m) => `"${title(m)}" tem nota média de ${rating(m)}/10 no TMDB.`,
      (m) => `"${title(m)}" é um filme popular com pontuação de ${pop(m)} no TMDB.`,
      (m) => dir(m) ? `"${title(m)}" foi dirigido por ${dir(m)}.` : null,
      (m) => run(m) ? `"${title(m)}" tem duração de ${run(m)} minutos.` : null,
      (m) => genre(m) ? `"${title(m)}" é um filme de ${genre(m)}.` : null,
    ];
  }
  if (lang === 'fr-CA') {
    return [
      (m) => `« ${title(m)} » est sorti en ${year(m)}.`,
      (m) => `« ${title(m)} » a une note moyenne de ${rating(m)}/10 sur TMDB.`,
      (m) => `« ${title(m)} » est un film populaire avec une cote de ${pop(m)} sur TMDB.`,
      (m) => dir(m) ? `« ${title(m)} » a été réalisé par ${dir(m)}.` : null,
      (m) => run(m) ? `« ${title(m)} » a une durée de ${run(m)} minutes.` : null,
      (m) => genre(m) ? `« ${title(m)} » est un film ${genre(m)}.` : null,
    ];
  }
  // en
  return [
    (m) => `"${title(m)}" was released in ${year(m)}.`,
    (m) => `"${title(m)}" has an average rating of ${rating(m)}/10 on TMDB.`,
    (m) => `"${title(m)}" is a popular film with a score of ${pop(m)} on TMDB.`,
    (m) => dir(m) ? `"${title(m)}" was directed by ${dir(m)}.` : null,
    (m) => run(m) ? `"${title(m)}" has a runtime of ${run(m)} minutes.` : null,
    (m) => genre(m) ? `"${title(m)}" is a ${genre(m)} film.` : null,
  ];
}

export function normalizeLang(lang: string | undefined): Lang {
  if (!lang) return 'en';
  const l = lang.split('-')[0].toLowerCase();
  const r = lang.includes('-') ? lang.split('-').slice(1).join('-').toUpperCase() : '';
  if (l === 'pt' && r === 'BR') return 'pt-BR';
  if (l === 'fr' && r === 'CA') return 'fr-CA';
  if (l === 'pt') return 'pt-BR';
  if (l === 'fr') return 'fr-CA';
  if (l === 'en') return 'en';
  return 'en';
}
