const request = require('supertest');
const app = require('../server');
const db = require('../config/db');

describe('Module 4 Integration Tests', () => {
  let token;
  let notificationId;

  beforeAll(async () => {
    // Register and login a user to get token
    await request(app).post('/api/auth/register').send({
      full_name: 'Module4 Test',
      email: 'm4@test.com',
      password: 'password123'
    });
    const loginRes = await request(app).post('/api/auth/login').send({
      email: 'm4@test.com',
      password: 'password123'
    });
    token = loginRes.body.token;

    // Inject a dummy notification directly into mock DB for testing
    const dbRes = await db.query(
      "INSERT INTO notifications (user_id, title, message) VALUES ($1, $2, $3) RETURNING *",
      [loginRes.body.user.id, "Test Notif", "Hello World"]
    );
    notificationId = dbRes.rows[0].id;
  });

  test('GET /api/notifications - Should return notifications', async () => {
    const res = await request(app)
      .get('/api/notifications')
      .set('Authorization', \`Bearer \${token}\`);
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.notifications.length).toBeGreaterThan(0);
  });

  test('POST /api/notifications/:id/read - Should mark read', async () => {
    const res = await request(app)
      .post(\`/api/notifications/\${notificationId}/read\`)
      .set('Authorization', \`Bearer \${token}\`);
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.notification.is_read).toBe(true);
  });

  test('PUT /api/settings - Should update settings', async () => {
    const res = await request(app)
      .put('/api/settings')
      .set('Authorization', \`Bearer \${token}\`)
      .send({ dark_mode: true, ai_model: 'gemini-pro', privacy_telemetry: false });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.settings.dark_mode).toBe(true);
  });

  test('POST /api/support/feedback - Should submit feedback', async () => {
    const res = await request(app)
      .post('/api/support/feedback')
      .set('Authorization', \`Bearer \${token}\`)
      .send({ rating: 5, comment: 'Great app' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.feedback.rating).toBe(5);
  });
});
