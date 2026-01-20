import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { fetchPopularMovie, getPosterUrl } from './utils/tmdb';
import { generateYearQuestion, generateCuriosity } from './utils/questionGenerator';

admin.initializeApp();

/**
 * Retorna o desafio do dia (ou gera se não existir)
 * GET /getDailyChallenge?date=YYYY-MM-DD (opcional, default: hoje)
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
      // Obter data (hoje ou parâmetro)
      const dateParam = req.query.date as string | undefined;
      const date = dateParam || getTodayDateString();

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
 * Helper: Retorna data de hoje no formato YYYY-MM-DD
 */
function getTodayDateString(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}
