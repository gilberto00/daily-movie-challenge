import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { fetchPopularMovie, fetchMovieDetails, getPosterUrl } from './utils/tmdb';
import { generateYearQuestion, generateCuriosity, generateRandomQuestion, generateQuestionByType } from './utils/questionGenerator';
import { normalizeLang, getUnknownDirector, type Lang } from './utils/translations';

admin.initializeApp();

/** Idioma da requisição: query.lang ou Accept-Language (primeiro preferido). */
function getLangFromRequest(req: functions.https.Request): string {
  const queryLang = req.query.lang as string | undefined;
  if (queryLang) return normalizeLang(queryLang);
  const accept = req.get('Accept-Language');
  if (accept) {
    const first = accept.split(',')[0]?.trim().replace('_', '-');
    return normalizeLang(first);
  }
  return normalizeLang(undefined);
}

function isUnknownAnswer(value: unknown): boolean {
  if (typeof value !== 'string') return false;
  const v = value.trim().toLowerCase();
  const unknowns = new Set<string>([
    getUnknownDirector('en' as Lang),
    getUnknownDirector('pt-BR' as Lang),
    getUnknownDirector('fr-CA' as Lang),
  ].map((s) => s.trim().toLowerCase()));
  return unknowns.has(v);
}

/**
 * Retorna o desafio do dia (ou gera se não existir)
 * GET /getDailyChallenge?date=YYYY-MM-DD&lang=pt-BR (lang opcional; usa idioma do sistema no app)
 */
export const getDailyChallenge = functions
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
      const dateParam = req.query.date as string | undefined;
      const date = dateParam || getTodayString();
      const lang = getLangFromRequest(req);

      const db = admin.firestore();
      const challengeRef = db.collection('dailyChallenges').doc(date);

      const existingDoc = await challengeRef.get();
      if (existingDoc.exists) {
        let data = existingDoc.data() as any;

        // Auto-heal: se um desafio antigo salvou "Unknown" nas opcoes (ou como resposta),
        // regeneramos usando detalhes completos do TMDB e atualizamos o documento.
        const hasUnknownOption = Array.isArray(data.options) && data.options.some((o: any) => isUnknownAnswer(o));
        const looksBrokenDirector = (data.questionType === 'director') && (isUnknownAnswer(data.correctAnswer) || hasUnknownOption);
        if (looksBrokenDirector) {
          const movie = await fetchMovieDetails(data.movieId);
          if (movie) {
            const fixed = generateQuestionByType('director', movie, 'en');
            const fixedCuriosity = generateCuriosity(movie, 'en');
            const patch = {
              question: fixed.question,
              options: fixed.options,
              correctAnswer: fixed.correctAnswer,
              questionType: fixed.questionType,
              curiosity: fixedCuriosity,
              healedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await challengeRef.set(patch, { merge: true });
            data = { ...data, ...patch };
          }
        }

        // Se idioma não for inglês, traduzir pergunta/curiosidade mantendo o tipo original
        if (lang !== 'en') {
          const movie = await fetchMovieDetails(data.movieId);
          if (movie) {
            const questionData = generateQuestionByType(
              data.questionType ?? 'year',
              movie,
              lang as 'pt-BR' | 'fr-CA'
            );
            const curiosity = generateCuriosity(movie, lang as 'pt-BR' | 'fr-CA');
            res.json({
              ...data,
              question: questionData.question,
              options: questionData.options,
              correctAnswer: questionData.correctAnswer,
              questionType: questionData.questionType,
              curiosity,
            });
            return;
          }
        }
        res.json(data);
        return;
      }

      // Gerar novo challenge (armazenar em inglês; resposta traduzida ao devolver se lang !== en)
      const movie = await fetchPopularMovie();
      // Alguns tipos de pergunta (director/runtime/genre) precisam de dados que NÃO vêm em /movie/popular.
      // Então buscamos detalhes completos antes de gerar a pergunta.
      const detailedMovie = (await fetchMovieDetails(movie.id)) ?? movie;
      const questionData = generateRandomQuestion(detailedMovie, [], 'en');
      const curiosity = generateCuriosity(detailedMovie, 'en');

      const challenge = {
        id: date,
        movieId: detailedMovie.id,
        title: detailedMovie.title,
        posterUrl: getPosterUrl(detailedMovie.poster_path),
        question: questionData.question,
        options: questionData.options,
        correctAnswer: questionData.correctAnswer,
        questionType: questionData.questionType,
        curiosity: curiosity,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await challengeRef.set(challenge);

      if (lang !== 'en') {
        const questionDataLang = generateQuestionByType(
          questionData.questionType,
          detailedMovie,
          lang as 'pt-BR' | 'fr-CA'
        );
        const curiosityLang = generateCuriosity(detailedMovie, lang as 'pt-BR' | 'fr-CA');
        res.json({
          ...challenge,
          question: questionDataLang.question,
          options: questionDataLang.options,
          correctAnswer: questionDataLang.correctAnswer,
          questionType: questionDataLang.questionType,
          curiosity: curiosityLang
        });
      } else {
        res.json(challenge);
      }
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

      const lang = getLangFromRequest(req);
      const questionData = generateRandomQuestion(movie, excludeTypes, lang as 'en' | 'pt-BR' | 'fr-CA');
      const curiosity = generateCuriosity(movie, lang as 'en' | 'pt-BR' | 'fr-CA');
      
      // Gerar ID único baseado em timestamp e random string para evitar duplicatas
      const uniqueId = `${movieId}-${questionData.questionType}-${Date.now()}-${Math.random().toString(36).substring(7)}`;

      res.json({
        id: uniqueId,
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
      const lang = getLangFromRequest(req);
      const movie = await fetchPopularMovie();
      const questionData = generateYearQuestion(movie, lang as 'en' | 'pt-BR' | 'fr-CA');
      const curiosity = generateCuriosity(movie, lang as 'en' | 'pt-BR' | 'fr-CA');

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
 * Helper: Retorna data de hoje no formato YYYY-MM-DD (um desafio por dia)
 */
function getTodayString(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Helper: Retorna o início do dia (00:00) no fuso informado.
 */
function getStartOfTodayInTimeZone(timeZone: string): Date {
  const now = new Date();
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  }).formatToParts(now);
  const year = Number(parts.find(p => p.type === 'year')?.value);
  const month = Number(parts.find(p => p.type === 'month')?.value);
  const day = Number(parts.find(p => p.type === 'day')?.value);
  const utcMidnight = new Date(Date.UTC(year, month - 1, day, 0, 0, 0));
  const tzDateString = utcMidnight.toLocaleString('en-US', { timeZone });
  const tzDate = new Date(tzDateString);
  const offsetMs = utcMidnight.getTime() - tzDate.getTime();
  return new Date(utcMidnight.getTime() + offsetMs);
}

/**
 * Helper: Formata data em YYYY-MM-DD no fuso informado.
 */
function formatDateInTimeZone(date: Date, timeZone: string): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  }).format(date);
}

/**
 * Notificação diária de novo desafio (9h da manhã)
 * Scheduled function via Cloud Scheduler
 */
export const sendDailyChallengeNotification = functions
  .region('us-central1')
  .pubsub
  .schedule('0 9 * * *') // 9h todo dia (horário local)
  .timeZone('America/Toronto')
  .onRun(async (context) => {
    try {
      const db = admin.firestore();
      const messaging = admin.messaging();
      const timeZone = 'America/Toronto';
      
      // Buscar usuários que já completaram o desafio hoje (para não enviar notificação)
      const startOfDay = getStartOfTodayInTimeZone(timeZone);
      const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);
      const completedSnapshot = await db.collection('users')
        .where('lastChallengeDate', '>=', admin.firestore.Timestamp.fromDate(startOfDay))
        .where('lastChallengeDate', '<', admin.firestore.Timestamp.fromDate(endOfDay))
        .get();
      const completedUserIds = new Set<string>(completedSnapshot.docs.map(doc => doc.id));
      
      // Buscar todos os tokens FCM de usuários que têm notificações diárias habilitadas
      const tokensSnapshot = await db.collection('fcmTokens').get();
      const settingsSnapshot = await db.collection('notificationSettings').get();
      
      // Criar mapa de settings por userId
      const settingsMap = new Map<string, any>();
      settingsSnapshot.forEach(doc => {
        settingsMap.set(doc.id, doc.data());
      });
      
      const tokens: string[] = [];
      tokensSnapshot.forEach(doc => {
        const userId = doc.id;
        const settings = settingsMap.get(userId);
        
        // Incluir apenas se dailyChallenge estiver habilitado (default: true)
        if (settings?.dailyChallenge !== false && !completedUserIds.has(userId)) {
          const token = doc.data().token;
          if (token) {
            tokens.push(token);
          }
        }
      });
      
      if (tokens.length === 0) {
        console.log('No tokens to send daily challenge notification');
        return null;
      }
      
      // Buscar desafio do dia (um por dia)
      const today = getTodayString();
      const challengeDoc = await db.collection('dailyChallenges').doc(today).get();
      let movieTitle = 'filmes';
      
      if (challengeDoc.exists) {
        const challengeData = challengeDoc.data();
        movieTitle = challengeData?.title || 'filmes';
      }
      
      // Enviar notificação
      const message = {
        notification: {
          title: '🎬 Novo Desafio Disponível!',
          body: `Teste seus conhecimentos sobre ${movieTitle} hoje!`
        },
        data: {
          type: 'dailyChallenge',
          challengeId: today,
          screen: 'home'
        },
        tokens: tokens
      };
      
      const response = await messaging.sendEachForMulticast(message);
      console.log(`✅ Daily challenge notification sent to ${response.successCount} devices`);
      console.log(`❌ Failed: ${response.failureCount}`);
      if (response.failureCount > 0) {
        response.responses.forEach((resp, i) => {
          if (!resp.success && resp.error) {
            console.error(`  [${i}] token failed:`, resp.error.code, resp.error.message);
          }
        });
      }
      
      return null;
    } catch (error) {
      console.error('❌ Error sending daily challenge notification:', error);
      return null;
    }
  });

/**
 * Notificação de streak em risco (20h)
 * Verifica usuários com streak > 0 que não completaram desafio do dia
 */
export const sendStreakReminderNotification = functions
  .region('us-central1')
  .pubsub
  .schedule('0 20 * * *') // 20h todo dia (horário local)
  .timeZone('America/Toronto')
  .onRun(async (context) => {
    try {
      const db = admin.firestore();
      const messaging = admin.messaging();
      const timeZone = 'America/Toronto';
      const today = formatDateInTimeZone(new Date(), timeZone);
      
      // Buscar usuários com streak > 0
      const usersSnapshot = await db.collection('users')
        .where('streak', '>', 0)
        .get();
      
      const tokensToSend: { token: string; streak: number }[] = [];
      
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const streak = userData.streak || 0;
        const lastChallengeDate = userData.lastChallengeDate;
        
        // Verificar se completou desafio hoje
        const completedToday = lastChallengeDate && 
          formatDateInTimeZone(lastChallengeDate.toDate(), timeZone) === today;
        
        if (!completedToday) {
          // Verificar settings de notificação
          const settingsDoc = await db.collection('notificationSettings').doc(userId).get();
          const settings = settingsDoc.data();
          
          // Incluir apenas se streakReminder estiver habilitado (default: true)
          if (settings?.streakReminder !== false) {
            // Buscar token FCM
            const tokenDoc = await db.collection('fcmTokens').doc(userId).get();
            if (tokenDoc.exists) {
              const token = tokenDoc.data()?.token;
              if (token) {
                tokensToSend.push({ token, streak });
              }
            }
          }
        }
      }
      
      if (tokensToSend.length === 0) {
        console.log('No users need streak reminder');
        return null;
      }
      
      // Enviar notificações individuais
      const promises = tokensToSend.map(({ token, streak }) => {
        return messaging.send({
          token: token,
          notification: {
            title: '🔥 Não Perca Sua Streak!',
            body: `Você tem uma streak de ${streak} dias! Complete o desafio de hoje para mantê-la.`
          },
          data: {
            type: 'streakReminder',
            streak: streak.toString(),
            screen: 'home'
          }
        });
      });
      
      const results = await Promise.allSettled(promises);
      const successCount = results.filter(r => r.status === 'fulfilled').length;
      const failureCount = results.filter(r => r.status === 'rejected').length;
      
      console.log(`✅ Streak reminder sent to ${successCount} users`);
      console.log(`❌ Failed: ${failureCount}`);
      
      return null;
    } catch (error) {
      console.error('❌ Error sending streak reminder:', error);
      return null;
    }
  });

/**
 * Trigger function para notificação de badge/conquista
 * Dispara quando novo badge é adicionado ao usuário
 */
export const onBadgeAwarded = functions
  .region('us-central1')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      const userId = context.params.userId;
      
      const beforeBadges = (before.badges || []) as string[];
      const afterBadges = (after.badges || []) as string[];
      
      // Verificar se novo badge foi adicionado
      const newBadges = afterBadges.filter(b => !beforeBadges.includes(b));
      
      if (newBadges.length === 0) {
        return null;
      }
      
      // Verificar settings de notificação
      const db = admin.firestore();
      const settingsDoc = await db.collection('notificationSettings').doc(userId).get();
      const settings = settingsDoc.data();
      
      // Incluir apenas se achievements estiver habilitado (default: true)
      if (settings?.achievements === false) {
        return null;
      }
      
      // Buscar token FCM
      const tokenDoc = await db.collection('fcmTokens').doc(userId).get();
      if (!tokenDoc.exists) {
        return null;
      }
      
      const token = tokenDoc.data()?.token;
      if (!token) {
        return null;
      }
      
      // Mapear nome do badge
      const badgeNames: { [key: string]: string } = {
        'streak_7': 'Streak de 7 Dias 🔥',
        'streak_30': 'Streak de 30 Dias 🔥🔥',
        'challenges_100': '100 Desafios Completados 🎯',
        'accuracy_80': 'Taxa de Acerto ≥ 80% ⭐'
      };
      
      const badgeName = badgeNames[newBadges[0]] || newBadges[0];
      
      // Enviar notificação
      const messaging = admin.messaging();
      await messaging.send({
        token: token,
        notification: {
          title: '🏆 Nova Conquista!',
          body: `Parabéns! Você alcançou: ${badgeName}`
        },
        data: {
          type: 'achievement',
          badge: newBadges[0],
          screen: 'leaderboard'
        }
      });
      
      console.log(`✅ Achievement notification sent to user ${userId}`);
      return null;
    } catch (error) {
      console.error('❌ Error sending achievement notification:', error);
      return null;
    }
  });
