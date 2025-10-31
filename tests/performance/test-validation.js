/**
 * Script de validation des configurations de test Artillery
 * Vérifie que les fichiers nécessaires existent et sont accessibles
 */

const fs = require('fs');
const path = require('path');

console.log('🔍 Validation des configurations de test Artillery...\n');

// Fichiers à vérifier
const files = [
  { path: 'scenarios/normal-load.yml', type: 'Scénario' },
  { path: 'scenarios/stress-test.yml', type: 'Scénario' },
  { path: 'scenarios/spike-test.yml', type: 'Scénario' },
  { path: 'configs/iaas-config.yml', type: 'Config' },
  { path: 'configs/paas-config.yml', type: 'Config' },
  { path: 'configs/test-data.csv', type: 'Data' },
  { path: 'processors/custom-functions.js', type: 'Processor' }
];

let allValid = true;
let validCount = 0;

files.forEach(file => {
  const fullPath = path.join(__dirname, file.path);

  try {
    if (!fs.existsSync(fullPath)) {
      console.log(`❌ ${file.type}: ${file.path} - FICHIER MANQUANT`);
      allValid = false;
      return;
    }

    const content = fs.readFileSync(fullPath, 'utf8');
    const stats = fs.statSync(fullPath);

    // Validation selon le type
    if (file.path.endsWith('.yml')) {
      // Vérifications basiques de syntaxe YAML
      if (file.type === 'Scénario') {
        if (!content.includes('config:')) {
          console.log(`⚠️  ${file.type}: ${file.path} - MANQUE section 'config:'`);
          allValid = false;
          return;
        }
        if (!content.includes('scenarios:')) {
          console.log(`⚠️  ${file.type}: ${file.path} - MANQUE section 'scenarios:'`);
          allValid = false;
          return;
        }
      }

      console.log(`✅ ${file.type}: ${file.path} - OK (${stats.size} bytes)`);
      validCount++;
    } else if (file.path.endsWith('.csv')) {
      const lines = content.split('\n').filter(l => l.trim());
      console.log(`✅ ${file.type}: ${file.path} - OK (${lines.length} lignes)`);
      validCount++;
    } else if (file.path.endsWith('.js')) {
      // Vérifier que c'est du JS valide
      try {
        require(fullPath);
        console.log(`✅ ${file.type}: ${file.path} - OK`);
        validCount++;
      } catch (err) {
        console.log(`❌ ${file.type}: ${file.path} - Erreur JS: ${err.message}`);
        allValid = false;
      }
    }

  } catch (error) {
    console.log(`❌ ${file.type}: ${file.path} - ERREUR: ${error.message}`);
    allValid = false;
  }
});

console.log('\n' + '='.repeat(60));
if (allValid) {
  console.log(`✅ Validation réussie ! (${validCount}/${files.length} fichiers OK)`);
  console.log('\n📝 Prochaines étapes:');
  console.log('   1. Configure les URLs dans configs/iaas-config.yml et paas-config.yml');
  console.log('   2. Définis les variables d\'environnement:');
  console.log('      - IAAS_URL=http://your-iaas-url.com');
  console.log('      - PAAS_URL=https://your-paas-url.com');
  console.log('   3. Lance un test: artillery run -e iaas scenarios/normal-load.yml');
  process.exit(0);
} else {
  console.log(`❌ Validation échouée`);
  process.exit(1);
}
