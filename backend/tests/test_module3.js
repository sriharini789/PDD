const request = require('supertest');
const app = require('../server');
const db = require('../config/db');

describe('Module 3 Integration Tests', () => {
  let token;
  let paperId;

  beforeAll(async () => {
    // Register and login a user to get token
    await request(app).post('/api/auth/register').send({
      full_name: 'Module3 Test',
      email: 'm3@test.com',
      password: 'password123'
    });
    const loginRes = await request(app).post('/api/auth/login').send({
      email: 'm3@test.com',
      password: 'password123'
    });
    token = loginRes.body.token;

    // Upload a dummy paper to get a paperId
    const uploadRes = await request(app)
      .post('/api/papers/upload')
      .set('Authorization', \`Bearer \${token}\`)
      .send({
        title: 'Test Paper for Module 3',
        authors: 'John Doe',
        fileName: 'test.pdf',
        fileSize: '1MB'
      });
    paperId = uploadRes.body.paper.id;
  });

  test('GET /api/search - Should return empty or matching results', async () => {
    const res = await request(app)
      .get('/api/search?q=Test')
      .set('Authorization', \`Bearer \${token}\`);
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.results).toBeInstanceOf(Array);
  });

  test('POST /api/library/reading-list - Should create list', async () => {
    const res = await request(app)
      .post('/api/library/reading-list')
      .set('Authorization', \`Bearer \${token}\`)
      .send({ name: 'My AI Papers' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.list.name).toBe('My AI Papers');
  });

  test('POST /api/library/papers/:id/favorite - Should toggle favorite', async () => {
    const res = await request(app)
      .post(\`/api/library/papers/\${paperId}/favorite\`)
      .set('Authorization', \`Bearer \${token}\`)
      .send({ is_favorite: true });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.paper.is_favorite).toBe(true);
  });

  test('POST /api/notes/papers/:id/notes - Should add note', async () => {
    const res = await request(app)
      .post(\`/api/notes/papers/\${paperId}/notes\`)
      .set('Authorization', \`Bearer \${token}\`)
      .send({ content: 'Important finding', highlighted_text: 'The accuracy is 99%', page_number: 2 });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.note.content).toBe('Important finding');
  });
});
