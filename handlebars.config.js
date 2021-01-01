// Import Handlebars runtime lib
const fs = require('fs');
const handlebars = require('handlebars');
const layouts = require('handlebars-layouts');

// Register helpers
handlebars.registerHelper(layouts(handlebars));

// Register partials
handlebars.registerPartial('layout', fs.readFileSync('src/templates/layouts/layout.hbs', 'utf8'));

/**
 * Handlebars runtime with custom helpers.
 * Used by handlebars-loader.
 */
module.exports = handlebars;
