import { expect } from 'chai';
import fs from 'fs';
import path from 'path';

describe('06. Validation, Lint & Config Verification Module', function () {
  this.timeout(10000);

  it('TC_301: Lint configuration check', async () => {
    const eslintConfigPath = path.resolve(process.cwd(), 'eslint.config.js');
    const exists = fs.existsSync(eslintConfigPath);
    expect(exists).to.be.true;
    
    const content = fs.readFileSync(eslintConfigPath, 'utf8');
    expect(content).to.include('js.configs.recommended');
  });

  it('TC_302: Semantic HTML body tags validation', async () => {
    // Check that we use semantic layout components in major page templates and components
    const srcDir = path.resolve(process.cwd(), 'src');
    
    const scanDir = (dir) => {
      let results = [];
      const list = fs.readdirSync(dir);
      list.forEach((file) => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat && stat.isDirectory()) {
          results = results.concat(scanDir(fullPath));
        } else if (file.endsWith('.jsx')) {
          results.push(fullPath);
        }
      });
      return results;
    };

    const files = scanDir(srcDir);
    expect(files.length).to.be.greaterThan(0);

    let hasSemanticTag = false;
    const semanticTags = ['<header', '<main', '<nav', '<footer', '<aside'];

    for (const file of files) {
      const content = fs.readFileSync(file, 'utf8');
      if (semanticTags.some(tag => content.includes(tag))) {
        hasSemanticTag = true;
        break;
      }
    }

    expect(hasSemanticTag).to.be.true;
  });

  it('TC_303: Form Input accessibility validation', async () => {
    // Verify that key form components define input accessibility properties (placeholder, aria-label, etc.)
    const fileToVerify = path.resolve(process.cwd(), 'src/pages/auth/RegisterPatient.jsx');
    expect(fs.existsSync(fileToVerify)).to.be.true;

    const content = fs.readFileSync(fileToVerify, 'utf8');
    // Check that we have input elements with either aria-label, placeholder or label mappings
    const hasInputFields = content.includes('<input');
    expect(hasInputFields).to.be.true;
    
    const hasAccessibility = content.includes('placeholder') || content.includes('aria-label') || content.includes('htmlFor');
    expect(hasAccessibility).to.be.true;
  });

  it('TC_304: Configuration schema verification', async () => {
    const pkgPath = path.resolve(process.cwd(), 'package.json');
    expect(fs.existsSync(pkgPath)).to.be.true;

    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
    expect(pkg).to.have.property('name');
    expect(pkg).to.have.property('version');
    expect(pkg).to.have.property('scripts');
    expect(pkg.scripts).to.have.property('build');
    expect(pkg.scripts).to.have.property('dev');
  });
});
