import { expect } from 'chai';
import { BASE_URL } from './config.js';

describe('08. Load Testing & Performance Benchmark Module', function () {
  this.timeout(30000);

  let latencies = [];
  let errorCount = 0;
  const totalRequests = 100;
  let durationMs = 0;

  before(async () => {
    const promises = [];
    const start = Date.now();
    
    for (let i = 0; i < totalRequests; i++) {
      const pStart = Date.now();
      promises.push(
        fetch(BASE_URL)
          .then((res) => {
            const pEnd = Date.now();
            if (res.status === 200) {
              latencies.push(pEnd - pStart);
            } else {
              errorCount++;
            }
          })
          .catch(() => {
            errorCount++;
          })
      );
    }
    
    await Promise.all(promises);
    durationMs = Date.now() - start;
  });

  it('TC_321: High-concurrency landing page load', () => {
    expect(latencies.length + errorCount).to.equal(totalRequests);
    expect(latencies.length).to.be.greaterThan(0);
  });

  it('TC_322: Load test average latency constraint', () => {
    const avg = latencies.reduce((a, b) => a + b, 0) / latencies.length;
    // Vite dev server loads extremely fast on localhost. We assert < 350ms to be safe in CI.
    expect(avg).to.be.lessThan(350);
  });

  it('TC_323: Load test response error rate check', () => {
    const errorRate = (errorCount / totalRequests) * 100;
    expect(errorRate).to.equal(0);
  });

  it('TC_324: Load test throughput capacity', () => {
    const rps = (totalRequests / (durationMs / 1000));
    // We expect the local server to easily process > 100 requests/sec throughput
    expect(rps).to.be.greaterThan(100);
  });
});
