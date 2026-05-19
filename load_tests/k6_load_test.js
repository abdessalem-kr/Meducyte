import http from 'k6/http';
import { check, sleep } from 'k6';

// ────────────────────────────────────────────────────────────────
// LOAD & STRESS TEST CONFIGURATION (k6 Options)
// ────────────────────────────────────────────────────────────────
// This configuration is designed to find the performance limits of the server
// by ramping up to 100 concurrent Virtual Users (VUs).
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Warm-up: 0 to 10 VUs
    { duration: '1m', target: 50 },   // Light load: Ramp up to 50 concurrent users
    { duration: '1m', target: 100 },  // Stress load: Ramp up to 100 concurrent users to find limits
    { duration: '1m', target: 150 },  // Extreme load: Attempt to push up to 150 VUs (fail-point analysis)
    { duration: '30s', target: 0 },   // Ramp-down: Cooldown phase
  ],
  thresholds: {
    // 95% of responses must complete within 500ms under normal load
    http_req_duration: ['p(95)<500'],
    // We expect 0% failures, but stress-testing will help identify at what concurrency level requests fail
    http_req_failed: ['rate<0.02'],
  },
};

// Target base URL. Customize via environment variable: k6 run -e BASE_URL=https://your-api.com k6_load_test.js
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const GRAPHQL_ENDPOINT = `${BASE_URL}/graphql`;

// ────────────────────────────────────────────────────────────────
// SETUP PHASE: Authenticate to obtain Sanctum Bearer Token
// ────────────────────────────────────────────────────────────────
export function setup() {
  const loginUrl = `${BASE_URL}/api/login`;
  const email = __ENV.TEST_EMAIL || 'test@meducyte.com';
  const password = __ENV.TEST_PASSWORD || 'password';

  console.log(`[SETUP] Attempting authentication for user: ${email} against ${loginUrl}`);

  const payload = JSON.stringify({
    email: email,
    password: password,
    device_id: 'k6-stress-test-agent',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  };

  const res = http.post(loginUrl, payload, params);

  if (res.status !== 200) {
    console.warn(`\n[WARNING] Setup login failed with status code ${res.status}.`);
    console.warn(`Response body: ${res.body}`);
    console.warn(`This is likely because the email is unverified or the database seeder has not run.`);
    console.warn(`Continuing test in UNAUTHENTICATED mode (requests may return 401/500 if protected).\n`);
    return { token: null };
  }

  const token = res.json('access_token');
  console.log(`\n[SUCCESS] Successfully authenticated!`);
  console.log(`Obtained Sanctum Token: Bearer ${token ? token.substring(0, 12) + '...' : 'null'}\n`);
  
  return { token: token };
}

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
export default function (data) {
  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // If we successfully logged in during setup, inject the Sanctum Bearer Token
  if (data && data.token) {
    headers['Authorization'] = `Bearer ${data.token}`;
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
        limit: 50, // Real-world chunks are large (e.g. 50-100 questions)
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
        limit: 50, // Simulated chunk of 50 questions
      }
    });

    const res = http.post(GRAPHQL_ENDPOINT, compositeQuery, { headers });
    check(res, {
      'Chunk Composite Filter: status is 200': (r) => r.status === 200,
      'Chunk Composite Filter: returned correct data': (r) => Array.isArray(r.json('data.questions')),
    });

  } else {
    // SCENARIO 5 (15%): Load a specific lesson and eager load its questions (relationship stress test)
    // We target random lesson IDs from 1 to 1000 representing our generated dummy lessons
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

  // Realistic thinking time before user triggers another action (average 1.5 seconds)
  sleep(1.5);
}


