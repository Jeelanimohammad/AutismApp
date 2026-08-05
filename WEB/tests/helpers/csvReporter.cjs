const mocha = require('mocha');
const fs = require('fs');
const path = require('path');

const {
  EVENT_TEST_PASS,
  EVENT_TEST_FAIL,
  EVENT_RUN_END,
} = mocha.Runner.constants;

const Spec = mocha.reporters.Spec;

class CsvReporter extends Spec {
  constructor(runner, options) {
    super(runner, options);
    
    this.results = [];

    runner.on(EVENT_TEST_PASS, (test) => {
      this.results.push({
        category: test.parent ? test.parent.fullTitle() : 'Default',
        title: test.title,
        status: 'PASSED',
        error: ''
      });
    });

    runner.on(EVENT_TEST_FAIL, (test, err) => {
      this.results.push({
        category: test.parent ? test.parent.fullTitle() : 'Default',
        title: test.title,
        status: 'FAILED',
        error: err.message
      });
    });

    runner.on(EVENT_RUN_END, () => {
      const csvPath = process.env.TEST_REPORT_PATH || path.resolve(process.cwd(), 'tests_report.csv');
      
      const escape = (val) => {
        if (val === undefined || val === null) return '';
        let str = String(val).replace(/"/g, '""');
        if (str.includes(',') || str.includes('\n') || str.includes('"')) {
          str = `"${str}"`;
        }
        return str;
      };

      const headers = ["Category", "Test Case Title", "Status", "Failure Reason / Action if Failed"];
      const rows = [headers];

      for (const res of this.results) {
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
          action
        ]);
      }

      const csvContent = rows.map(r => r.map(escape).join(',')).join('\n');
      fs.writeFileSync(csvPath, csvContent, 'utf8');
      console.log(`\n📊 E2E Test Report successfully generated at: ${csvPath}\n`);
    });
  }
}

module.exports = CsvReporter;
