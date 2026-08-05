const mocha = require('mocha');
const fs = require('fs');
const path = require('path');

const {
  EVENT_RUN_BEGIN,
  EVENT_TEST_PASS,
  EVENT_TEST_FAIL,
  EVENT_RUN_END,
} = mocha.Runner.constants;

const Base = mocha.reporters.Base;

class CsvReporter extends Base {
  constructor(runner, options) {
    super(runner, options);
    
    this.results = [];
    this.currentIndex = 0;

    runner.on(EVENT_RUN_BEGIN, () => {
      this.totalTests = runner.total || 46;
      this.currentIndex = 0;
      this.startTime = Date.now();
      console.log('\n=========================== test session starts ===========================');
      console.log(`collecting ... collected ${this.totalTests} items\n`);
    });

    runner.on(EVENT_TEST_PASS, (test) => {
      this.currentIndex++;
      const percent = Math.floor((this.currentIndex / this.totalTests) * 100);
      const percentStr = `[ ${String(percent).padStart(2, ' ')}%]`;
      
      const categoryRaw = test.parent ? test.parent.fullTitle() : 'AutismSuite';
      const suiteName = categoryRaw.replace(/[^a-zA-Z0-9_]/g, '_').replace(/_+/g, '_');
      const tcNum = String(this.currentIndex).padStart(3, '0');
      const titleFormatted = test.title.replace(/[^a-zA-Z0-9_]/g, '_').replace(/_+/g, '_').toLowerCase();
      const tcName = `test_TC_${tcNum}_${titleFormatted}`;

      const logLine = `test_autism.js::${suiteName}::${tcName} PASSED ${percentStr}`;
      console.log(logLine);

      this.results.push({
        category: categoryRaw,
        title: test.title,
        tcName: tcName,
        status: 'PASSED',
        duration: test.duration || 0,
        percent: `${percent}%`,
        error: ''
      });
    });

    runner.on(EVENT_TEST_FAIL, (test, err) => {
      this.currentIndex++;
      const percent = Math.floor((this.currentIndex / this.totalTests) * 100);
      const percentStr = `[ ${String(percent).padStart(2, ' ')}%]`;
      
      const categoryRaw = test.parent ? test.parent.fullTitle() : 'AutismSuite';
      const suiteName = categoryRaw.replace(/[^a-zA-Z0-9_]/g, '_').replace(/_+/g, '_');
      const tcNum = String(this.currentIndex).padStart(3, '0');
      const titleFormatted = test.title.replace(/[^a-zA-Z0-9_]/g, '_').replace(/_+/g, '_').toLowerCase();
      const tcName = `test_TC_${tcNum}_${titleFormatted}`;

      const logLine = `test_autism.js::${suiteName}::${tcName} FAILED ${percentStr}`;
      console.log(logLine);

      this.results.push({
        category: categoryRaw,
        title: test.title,
        tcName: tcName,
        status: 'FAILED',
        duration: test.duration || 0,
        percent: `${percent}%`,
        error: err ? err.message : 'Unknown error'
      });
    });

    runner.on(EVENT_RUN_END, () => {
      const elapsedSec = ((Date.now() - (this.startTime || Date.now())) / 1000).toFixed(2);
      const csvPath = process.env.TEST_REPORT_PATH || path.resolve(process.cwd(), 'tests_report.csv');
      const jsonPath = path.resolve(path.dirname(csvPath), 'tests_summary.json');
      
      const escape = (val) => {
        if (val === undefined || val === null) return '';
        let str = String(val).replace(/"/g, '""');
        if (str.includes(',') || str.includes('\n') || str.includes('"')) {
          str = `"${str}"`;
        }
        return str;
      };

      const headers = ["Category", "Test Case Title", "Status", "Progress %", "Duration (ms)", "Failure Reason / Action if Failed"];
      const rows = [headers];

      let passedCount = 0;
      let failedCount = 0;

      for (const res of this.results) {
        if (res.status === 'PASSED') passedCount++;
        else failedCount++;

        let action = '';
        if (res.status === 'FAILED') {
          action = `Error: ${res.error}\n\nTroubleshooting:\n`;
          if (res.category.includes('Authentication')) {
            action += `- Verify Vite dev server is running on port 5174.\n- Check elements/selectors in the login/registration pages.`;
          } else if (res.category.includes('Doctor')) {
            action += `- Check that sessionStorage values are correctly set.\n- Verify Doctor dashboard routes & elements.`;
          } else if (res.category.includes('Patient')) {
            action += `- Check that sessionStorage values are correctly set.\n- Verify Patient dashboard routes & elements.`;
          } else {
            action += `- Verify the application state and selectors.`;
          }
        } else {
          action = 'N/A (Test Passed)';
        }

        rows.push([
          res.category,
          res.title,
          res.status,
          res.percent,
          res.duration,
          action
        ]);
      }

      const totalCount = this.results.length;
      const passPercentage = totalCount > 0 ? ((passedCount / totalCount) * 100).toFixed(1) : '0';

      const csvContent = rows.map(r => r.map(escape).join(',')).join('\n');
      fs.writeFileSync(csvPath, csvContent, 'utf8');

      const summaryData = {
        total: totalCount,
        passed: passedCount,
        failed: failedCount,
        passPercentage: `${passPercentage}%`,
        results: this.results
      };
      fs.writeFileSync(jsonPath, JSON.stringify(summaryData, null, 2), 'utf8');

      console.log(`\n==================== ${passedCount} passed, ${failedCount} failed in ${elapsedSec}s (${passPercentage}% Pass Rate) ====================\n`);
    });
  }
}

module.exports = CsvReporter;
