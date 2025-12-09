// generateFlutterDocs.js

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Setup paths for ES Module compatibility
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// CONFIGURATION:
// 1. Set the source to 'lib' (standard Flutter folder)
// 2. Set the output file name
const srcDirectory = path.join(__dirname, 'lib');
const outputFilePath = path.join(__dirname, 'flutter_code.md');

/**
 * Recursively reads a directory and generates a markdown string
 * specifically for .dart files.
 *
 * @param {string} directory - The path to the directory to read.
 * @returns {string} - A markdown-formatted string of all .dart file contents.
 */
function processDirectory(directory) {
  const markdownParts = [];

  try {
    const items = fs.readdirSync(directory, { withFileTypes: true });

    for (const item of items) {
      const fullPath = path.join(directory, item.name);

      if (item.isDirectory()) {
        // Recursively process subdirectories
        const subDirContent = processDirectory(fullPath);
        if (subDirContent) {
            markdownParts.push(subDirContent);
        }
      } else if (item.isFile()) {
        // FILTER: Only process .dart files
        if (path.extname(item.name) === '.dart') {
          try {
            const fileContent = fs.readFileSync(fullPath, 'utf8');

            // Get relative path (e.g., lib/main.dart)
            const relativePath = path.relative(__dirname, fullPath).replace(/\\/g, '/');

            // Construct the Markdown block
            // We hardcode 'dart' here since we know we are filtering for it
            const fileMarkdown = [
              `# ${relativePath}`,
              '```dart',
              fileContent.trim(),
              '```',
              '---',
            ].join('\n');

            markdownParts.push(fileMarkdown);
          } catch (readError) {
            console.warn(`⚠️ Could not read file: ${fullPath}. Skipping.`, readError);
          }
        }
      }
    }
  } catch (dirError) {
    console.warn(`⚠️ Could not read directory: ${directory}`, dirError);
  }

  return markdownParts.join('\n\n');
}

// --- Main Execution ---
try {
  console.log(`Starting to process .dart files from '${srcDirectory}'...`);

  if (!fs.existsSync(srcDirectory)) {
    throw new Error(`Directory not found: ${srcDirectory}. Are you in the root of your Flutter project?`);
  }

  const finalMarkdown = processDirectory(srcDirectory);

  if (finalMarkdown.length === 0) {
      console.warn("⚠️ No .dart files were found or the output is empty.");
  } else {
      fs.writeFileSync(outputFilePath, finalMarkdown);
      console.log(`✅ Successfully created ${outputFilePath}`);
  }

} catch (error) {
  console.error('❌ An error occurred:', error.message);
  process.exit(1);
}