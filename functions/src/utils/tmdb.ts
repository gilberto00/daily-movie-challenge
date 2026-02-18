import axios from 'axios';

const TMDB_API_KEY = '7544e7dfbcf8aa5855a0f319f8488711';
const TMDB_BASE_URL = 'https://api.themoviedb.org/3';
const TMDB_IMAGE_BASE_URL = 'https://image.tmdb.org/t/p/w500';

export interface TMDBMovie {
  id: number;
  title: string;
  release_date: string;
  poster_path: string | null;
  overview: string;
  vote_average: number;
  popularity: number;
  director?: string;
  genres?: Array<{ id: number; name: string }>;
  runtime?: number;
  tagline?: string;
}

export interface TMDBPopularMoviesResponse {
  results: TMDBMovie[];
  page: number;
  total_pages: number;
  total_results: number;
}

/**
 * Busca um filme popular aleatório do TMDB
 */
export async function fetchPopularMovie(): Promise<TMDBMovie> {
  try {
    // Buscar filmes populares
    const response = await axios.get<TMDBPopularMoviesResponse>(
      `${TMDB_BASE_URL}/movie/popular`,
      {
        params: {
          api_key: TMDB_API_KEY,
          language: 'en-US',
          page: Math.floor(Math.random() * 10) + 1, // Página aleatória (1-10)
        },
      }
    );

    const movies = response.data.results;
    if (movies.length === 0) {
      throw new Error('No popular movies found');
    }

    // Selecionar filme aleatório
    const randomMovie = movies[Math.floor(Math.random() * movies.length)];
    return randomMovie;
  } catch (error) {
    console.error('Error fetching popular movie from TMDB:', error);
    throw error;
  }
}

/**
 * Busca detalhes completos de um filme pelo ID
 */
export async function fetchMovieDetails(movieId: number): Promise<TMDBMovie | null> {
  try {
    const response = await axios.get(
      `${TMDB_BASE_URL}/movie/${movieId}`,
      {
        params: {
          api_key: TMDB_API_KEY,
          language: 'en-US',
        },
      }
    );

    // Buscar informações de créditos para obter o diretor
    const creditsResponse = await axios.get(
      `${TMDB_BASE_URL}/movie/${movieId}/credits`,
      {
        params: {
          api_key: TMDB_API_KEY,
        },
      }
    );

    const director = creditsResponse.data.crew?.find(
      (person: any) => person.job === 'Director'
    )?.name;

    return {
      ...response.data,
      // Se não acharmos um diretor, preferimos omitir o campo em vez de injetar "Unknown".
      // Isso permite ao gerador evitar perguntas de diretor automaticamente.
      director: director ?? undefined,
    };
  } catch (error) {
    console.error(`Error fetching movie details for ID ${movieId}:`, error);
    return null;
  }
}

/**
 * Gera URL completa da imagem do poster
 */
export function getPosterUrl(posterPath: string | null): string | null {
  if (!posterPath) return null;
  return `${TMDB_IMAGE_BASE_URL}${posterPath}`;
}
