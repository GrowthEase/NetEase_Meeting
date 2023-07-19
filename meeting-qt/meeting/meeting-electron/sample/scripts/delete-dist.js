const path = require('path');
const fs = require('fs');

fs.rmdirSync(path.resolve(__dirname, '../src/dist'), { recursive: true });
