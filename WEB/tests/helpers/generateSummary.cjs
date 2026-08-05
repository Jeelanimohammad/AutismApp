const fs = require('fs');
const path = require('path');

const summaryPath = path.resolve(__dirname, '../../tests_summary.json');
const outputPath = process.env.GITHUB_STEP_SUMMARY || path.resolve(__dirname, '../../tests_summary.md');

if (!fs.existsSync(summaryPath)) {
  console.error('Summary file not found at:', summaryPath);
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(summaryPath, 'utf8'));

const total = data.total || 0;
const passed = data.passed || 0;
const failed = data.failed || 0;
const passRate = parseFloat(data.passPercentage || '0');

// Calculate 10-segment progress bar
const greenBlocks = Math.round(passRate / 10);
const redBlocks = 10 - greenBlocks;
const progressBar = '🟩'.repeat(greenBlocks) + '🟥'.repeat(redBlocks) + ` **${data.passPercentage}**`;

const testType = process.env.TEST_TYPE || 'Selenium Web E2E';
let markdown = `## 🧪 ${testType} Test Execution Summary\n\n`;

markdown += `| Total Testcases | Passed | Failed | Pass Percentage |\n`;
markdown += `| :---: | :---: | :---: | :---: |\n`;
markdown += `| **${total}** | **${passed}** ✅ | **${failed}** ❌ | **${data.passPercentage}** |\n\n`;

markdown += `### 📈 Overall Pass Rate\n${progressBar}\n\n`;

markdown += `### 📋 Detailed Testcases Results (${total} Total Testcases)\n\n`;
markdown += `| # | Status | Test Case Identifier | Title | Suite / Category | Progress % | Duration |\n`;
markdown += `| :---: | :--- | :--- | :--- | :--- | :---: | :---: |\n`;

data.results.forEach((res, index) => {
  const statusBadge = res.status === 'PASSED' ? '✅ **PASSED**' : '❌ **FAILED**';
  const durationSec = res.duration ? `${(res.duration / 1000).toFixed(2)}s` : '0s';
  const tcName = res.tcName || `test_TC_${String(index + 1).padStart(3, '0')}`;
  const title = res.title.replace(/\|/g, '\\|');
  const category = res.category.replace(/\|/g, '\\|');
  const percent = res.percent || `${Math.floor(((index + 1) / total) * 100)}%`;
  
  markdown += `| ${index + 1} | ${statusBadge} | \`${tcName}\` | ${title} | ${category} | \`${percent}\` | ${durationSec} |\n`;
});

if (failed > 0) {
  markdown += `\n### ❌ Failed Test Details & Troubleshooting\n\n`;
  data.results.filter(r => r.status === 'FAILED').forEach((res, idx) => {
    markdown += `#### ${idx + 1}. ${res.title}\n`;
    markdown += `- **Category:** ${res.category}\n`;
    markdown += `- **Error:** \`${res.error}\` \n\n`;
  });
}

fs.appendFileSync(outputPath, markdown, 'utf8');
console.log('Markdown Job Summary successfully generated!');
