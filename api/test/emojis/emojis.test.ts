import request from 'supertest';

import app from '../../src/app';

describe('GET /api/v1/emojis', () => {
  it('responds with a json message', (done) => {
    request(app)
      .get('/api/v1/emojis')
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(200, { message: 'Emoji router' }, done);
  });
});

describe('GET /api/v1/emojis/happy', () => {
  it('responds with a json message', (done) => {
    request(app)
      .get('/api/v1/emojis/happy')
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(200, { message: ['😀'] }, done);
  });
});

  
describe('GET /api/v1/emojis/sad', () => {
  it('responds with a json message', (done) => {
    request(app)
      .get('/api/v1/emojis/sad')
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(200, { message: ['😢'] }, done);
  });
});
  
