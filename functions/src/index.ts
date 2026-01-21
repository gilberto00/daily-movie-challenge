import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { fetchPopularMovie, fetchMovieDetails, getPosterUrl } from './utils/tmdb';
import { generateYearQuestion, generateCuriosity, generateRandomQuestion } from './utils/questionGenerator';

admin.initializeApp();

/**
 * Retorna o desafio da hora (ou gera se não existir)
 * GET /getDailyChallenge?date=YYYY-MM-DD-HH (opcional, default: hora atual)
 */
export const getDailyChallenge = functions
  .region('us-central1')
  .https
  .onRequest(async (req, res) => {
    // CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    try {
      // Obter data/hora (hora atual ou parâmetro)
      const dateParam = req.query.date as string | undefined;
      const date = dateParam || getCurrentHourString();

      const db = admin.firestore();
      const challengeRef = db.collection('dailyChallenges').doc(date);

      // Verificar se já existe
      const existingDoc = await challengeRef.get();
      if (existingDoc.exists) {
        const data = existingDoc.data();
        res.json(data);
        return;
      }

      // Gerar novo challenge
      const movie = await fetchPopularMovie();
      const questionData = generateYearQuestion(movie);
      const curiosity = generateCuriosity(movie);

      const challenge = {
        id: date,
        movieId: movie.id,
        title: movie.title,
        posterUrl: getPosterUrl(movie.poster_path),
        question: questionData.question,
        options: questionData.options,
        correctAnswer: questionData.correctAnswer,
        questionType: 'year',
        curiosity: curiosity,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Salvar no Firestore
      await challengeRef.set(challenge);

      // Retornar
      res.json(challenge);
    } catch (error) {
      console.error('Error in getDailyChallenge:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

/**
 * Retorna pergunta extra do mesmo filme
 * GET /getExtraQuestion?movieId=123&excludeTypes=year,director
 */
export const getExtraQuestion = functions
  .region('us-central1')
  .https
  .onRequest(async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    try {
      const movieId = parseInt(req.query.movieId as string);
      const excludeTypes = (req.query.excludeTypes as string || '').split(',').filter(Boolean);

      if (!movieId) {
        res.status(400).json({ error: 'movieId is required' });
        return;
      }

      // Buscar detalhes do filme no TMDB
      const movie = await fetchMovieDetails(movieId);
      if (!movie) {
        res.status(404).json({ error: 'Movie not found' });
        return;
      }

      // Gerar pergunta diferente (que não foi jogada ainda)
      const questionData = generateRandomQuestion(movie, excludeTypes);
      const curiosity = generateCuriosity(movie);

      res.json({
        id: `${movieId}-${questionData.questionType}-${Date.now()}`,
        movieId: movie.id,
        title: movie.title,
        posterUrl: getPosterUrl(movie.poster_path),
        question: questionData.question,
        options: questionData.options,
        correctAnswer: questionData.correctAnswer,
        questionType: questionData.questionType,
        curiosity: curiosity,
        isExtra: true,
      });
    } catch (error) {
      console.error('Error in getExtraQuestion:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

/**
 * Retorna novo desafio com filme diferente
 * GET /getNewMovieChallenge
 */
export const getNewMovieChallenge = functions
  .region('us-central1')
  .https
  .onRequest(async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    try {
      // Gerar novo filme e pergunta
      const movie = await fetchPopularMovie();
      const questionData = generateYearQuestion(movie);
      const curiosity = generateCuriosity(movie);

      const challenge = {
        id: `${movie.id}-${Date.now()}`,
        movieId: movie.id,
        title: movie.title,
        posterUrl: getPosterUrl(movie.poster_path),
        question: questionData.question,
        options: questionData.options,
        correctAnswer: questionData.correctAnswer,
        questionType: 'year',
        curiosity: curiosity,
        isExtra: true,
      };

      res.json(challenge);
    } catch (error) {
      console.error('Error in getNewMovieChallenge:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

/**
 * Helper: Retorna hora atual no formato YYYY-MM-DD-HH
 */
function getCurrentHourString(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hour = String(now.getHours()).padStart(2, '0');
  return `${year}-${month}-${day}-${hour}`;
}
