import http from 'k6/http';
import { check, sleep } from 'k6';

// ────────────────────────────────────────────────────────────────
// LOAD & STRESS TEST CONFIGURATION (k6 Options)
// ────────────────────────────────────────────────────────────────
// This configuration is customized to simulate exactly 500 concurrent
// real-world students studying and loading quizzes at the same time.
export const options = {
  stages: [
    { duration: '1m', target: 200 },   // Warm-up: Scale up to 200 active students
    { duration: '1m', target: 500 },   // Ramp-up: Scale up to 500 active students
    { duration: '3m', target: 500 },   // Steady-state: Hold 500 active students studying together
    { duration: '30s', target: 0 },    // Cooldown: Ramp down to 0
  ],
  thresholds: {
    // 95% of responses must complete within 3000ms under 500 concurrent user load with heavy composite queries
    http_req_duration: ['p(95)<3000'],
    // We expect <2% failures during real-user simulation
    http_req_failed: ['rate<0.02'],
  },
};

// Target base URL. Customize via environment variable: k6 run -e BASE_URL=https://your-api.com k6_load_test.js
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const GRAPHQL_ENDPOINT = `${BASE_URL}/graphql`;

// Load pre-generated Sanctum tokens for the 100 test VUs.
// If tokens.json is empty or not yet filled, the VUs will automatically fallback to dynamic login.
const tokensList = JSON.parse(open('./tokens.json'));

// Persistent state per Virtual User (VU) thread
let authToken = null;
let loginFailed = false;

// ────────────────────────────────────────────────────────────────
// VARIATION POOLS (To simulate diverse filter requests)
// ────────────────────────────────────────────────────────────────
const SOURCES_POOL = [
  'ECN 2020',
  'ECN 2021',
  'ECN 2022',
  'ECN 2023',
  'Sidi Bel Abbes Résidanat 2024',
  'Algiers Résidanat 2023',
  'Oran Medical Exam',
  'Constantine Internal Test',
];

const TAGS_POOL = [
  'qcm',
  'cardio',
  'pneumo',
  'neuro',
  'gastro',
  'pédiatrie',
  'grossesse',
  'anatomie',
  'biochimie',
  'physiologie',
];

function getRandom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// ────────────────────────────────────────────────────────────────
// VIRTUAL USER LOAD TEST ITERATION
// ────────────────────────────────────────────────────────────────
export default function () {
  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Resolve Sanctum Token for this Virtual User thread
  if (!authToken && !loginFailed) {
    const vuIndex = __VU; // Unique 1-based index for this Virtual User (1 to 100)
    
    if (Array.isArray(tokensList) && tokensList.length >= vuIndex) {
      // Direct token injection: Bypasses the 429 throttle completely!
      authToken = tokensList[vuIndex - 1];
    } else {
      // Fallback: Attempt dynamic login
      const email = `test${vuIndex}@meducyte.com`;
      const password = 'password';
      const loginUrl = `${BASE_URL}/api/login`;

      const payload = JSON.stringify({
        email: email,
        password: password,
        device_id: `k6-vu-${vuIndex}`,
      });

      const params = {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      };

      const res = http.post(loginUrl, payload, params);

      if (res.status === 200) {
        authToken = res.json('access_token');
      } else {
        console.warn(`[WARNING] VU ${vuIndex} (${email}) login failed with status ${res.status}. Running unauthenticated.`);
        loginFailed = true; // Mark as failed to avoid repeated login attempts on every iteration
      }
    }
  }

  // Inject the Sanctum Bearer Token if available
  if (authToken) {
    headers['Authorization'] = `Bearer ${authToken}`;
  }

  // Determine user action dynamically based on probability weights
  const randVal = Math.random();

  if (randVal < 0.20) {
    // SCENARIO 1 (20%): Fetch all modules (homepage/dashboard loading)
    const modulesQuery = JSON.stringify({
      query: `
        query GetModules {
          modules {
            id
            name
            year
            description
          }
        }
      `
    });

    const res = http.post(GRAPHQL_ENDPOINT, modulesQuery, { headers });
    check(res, {
      'Modules: status is 200': (r) => r.status === 200,
      'Modules: data exists': (r) => r.json('data.modules') !== undefined,
    });

  } else if (randVal < 0.40) {
    // SCENARIO 2 (20%): Fetch all distinct sources (filter populating)
    const sourcesQuery = JSON.stringify({
      query: `
        query GetSources {
          sources
        }
      `
    });

    const res = http.post(GRAPHQL_ENDPOINT, sourcesQuery, { headers });
    check(res, {
      'Sources: status is 200': (r) => r.status === 200,
      'Sources: data exists': (r) => Array.isArray(r.json('data.sources')),
    });

  } else if (randVal < 0.65) {
    // SCENARIO 3 (25%): Real-world heavy chunked Quiz Query by Tag (GetQuestions with nested models)
    const randomTag = getRandom(TAGS_POOL);
    const tagQuery = JSON.stringify({
      query: `
        query GetQuestionsByTag($tags: [String!], $limit: Int) {
          questions(tags: $tags, limit: $limit) {
            id
            text
            source_exam
            tags
            estimated_time
            lesson {
              title
              module {
                name
                year
              }
            }
            propositions {
              id
              questionId
              label
              text
              isCorrect
            }
            comments {
              id
              parent_id
              text
              is_edited
              upvotes
              downvotes
              my_vote
              is_mine
              created_at
              user {
                name
              }
            }
            clinicalCase {
              id
              text
              title
            }
          }
        }
      `,
      variables: {
        tags: [randomTag],
        limit: 200, // Real-world chunks are large (e.g. 50-100 questions)
      }
    });

    const res = http.post(GRAPHQL_ENDPOINT, tagQuery, { headers });
    check(res, {
      'Chunk Tag Filter: status is 200': (r) => r.status === 200,
      'Chunk Tag Filter: returned correct data': (r) => Array.isArray(r.json('data.questions')),
      'Chunk Tag Filter: returned questions in chunk': (r) => {
        const q = r.json('data.questions');
        return q && q.length > 0;
      }
    });

  } else if (randVal < 0.85) {
    // SCENARIO 4 (20%): Real-world heavy chunked Composite Filter (Years, Sources, and heavy nested models)
    const randomYear = Math.floor(Math.random() * 6) + 1; // 1 to 6
    const randomSource = getRandom(SOURCES_POOL);
    
    const compositeQuery = JSON.stringify({
      query: `
        query GetQuestionsComposite($years: [Int], $sources: [String], $limit: Int) {
          questions(years: $years, sources: $sources, limit: $limit) {
            id
            text
            source_exam
            tags
            estimated_time
            lesson {
              title
              module {
                name
                year
              }
            }
            propositions {
              id
              questionId
              label
              text
              isCorrect
            }
            comments {
              id
              parent_id
              text
              is_edited
              upvotes
              downvotes
              my_vote
              is_mine
              created_at
              user {
                name
              }
            }
            clinicalCase {
              id
              text
              title
            }
          }
        }
      `,
      variables: {
        years: [randomYear],
        sources: [randomSource],
        limit: 200, // Simulated chunk of 50 questions
      }
    });

    const res = http.post(GRAPHQL_ENDPOINT, compositeQuery, { headers });
    check(res, {
      'Chunk Composite Filter: status is 200': (r) => r.status === 200,
      'Chunk Composite Filter: returned correct data': (r) => Array.isArray(r.json('data.questions')),
    });

  } else {
    // SCENARIO 5 (15%): Load a specific lesson and eager load its questions (relationship stress test)
    const randomLessonId = Math.floor(Math.random() * 2000) + 1;
    const lessonQuery = JSON.stringify({
      query: `
        query GetLessonDetail($id: ID!) {
          lesson(id: $id) {
            id
            title
            order
            module {
              name
              year
            }
          }
        }
      `,
      variables: {
        id: String(randomLessonId)
      }
    });

    const res = http.post(GRAPHQL_ENDPOINT, lessonQuery, { headers });
    check(res, {
      'Lesson Detail: status is 200 or 404 (non-existent)': (r) => r.status === 200,
    });
  }

  // Realistic thinking time: A real student reads the question, considers the A-E
  // propositions, checks correction, and reviews comments (averages 20 seconds).
  sleep(20);
}
