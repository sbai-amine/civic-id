import Redis from 'ioredis';
import { RedisStore } from 'rate-limit-redis';
import { REDIS_URL } from '../config.js';

let _client;

/**
 * @returns {import('ioredis').default | null}
 */
export function getSharedRedis() {
  if (!REDIS_URL) return null;
  if (!_client) {
    _client = new Redis(REDIS_URL, { maxRetriesPerRequest: null });
    _client.on('error', (e) => {
      console.error('[bridgeid-api] Redis (rate limit):', e.message);
    });
  }
  return _client;
}

/**
 * @param {string} name prefix segment for this limiter
 * @returns {import('express-rate-limit').Store | undefined} undefined = use default memory store
 */
export function makeRedisStore(name) {
  const c = getSharedRedis();
  if (!c) return undefined;
  return new RedisStore({
    prefix: `bridgeid:rl:${name}:`,
    sendCommand: (command, ...args) => c.call(command, ...args),
  });
}

/**
 * Merges optional Redis `store` into a rate-limiter config; omits it when `REDIS_URL` is unset.
 * @param {string} name
 * @param {import('express-rate-limit').Options} options
 * @returns {import('express-rate-limit').Options}
 */
export function withOptionalRedisStore(name, options) {
  const store = makeRedisStore(name);
  if (!store) return options;
  return { ...options, store };
}
