import http from 'k6/http';
import { check, sleep } from 'k6';

// ────────────────────────────────────────────────────────────────
// LOAD TEST CONFIGURATION (k6 Options)
// ────────────────────────────────────────────────────────────────
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp-up: 0 to 10 virtual users (VUs)
    { duration: '1m', target: 30 },   // Stress: Load up to 30 VUs to test concurrent indexing
    { duration: '1m', target: 30 },   // Plateau: Stay at 30 VUs to evaluate database thermal throttling
    { duration: '15s', target: 0 },   // Ramp-down: Smoothly scale down VUs
  ],
  thresholds: {
    // 95% of responses must complete within 400ms (database indexes must be efficient!)
    http_req_duration: ['p(95)<400'],
    // Request failure rate must be under 1%
    http_req_failed: ['rate<0.01'],
  },
};

// Target base URL. Customize via environment variable: k6 run -e BASE_URL=https://your-api.com k6_load_test.js
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const GRAPHQL_ENDPOINT = `${BASE_URL}/graphql`;

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

// Helper to get random item from array
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
    // SCENARIO 3 (25%): Filter questions by random tag (Heavy JSON Contains test)
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
            approved
            propositions {
              id
              label
              text
              isCorrect
            }
          }
        }
      `,
      variables: {
        tags: [randomTag],
        limit: 15,
      }
    });

    const res = http.post(GRAPHQL_ENDPOINT, tagQuery, { headers });
    check(res, {
      'Tag Filter: status is 200': (r) => r.status === 200,
      'Tag Filter: returned correct data': (r) => Array.isArray(r.json('data.questions')),
    });

  } else if (randVal < 0.85) {
    // SCENARIO 4 (20%): Filter questions by year and source exam (Indexes composite testing)
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
            propositions {
              id
              label
              text
              isCorrect
            }
          }
        }
      `,
      variables: {
        years: [randomYear],
        sources: [randomSource],
        limit: 10,
      }
    });

    const res = http.post(GRAPHQL_ENDPOINT, compositeQuery, { headers });
    check(res, {
      'Composite Filter: status is 200': (r) => r.status === 200,
      'Composite Filter: returned correct data': (r) => Array.isArray(r.json('data.questions')),
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
