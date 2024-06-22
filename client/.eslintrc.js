module.exports = {
  extends: ['eslint:recommended','plugin:@typescript-eslint/eslint-recommended','plugin:@typescript-eslint/recommended', 'plugin:storybook/recommended', 'next'],
  root: true,
  env: {
    jest: true,
    node: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: ['./tsconfig.json'],
    tsconfigRootDir: __dirname,
  },
  ignorePatterns: ['.eslintrc.js', '*.config.js'],  // Add this line to ignore .eslintrc.js
  plugins: [
    '@typescript-eslint',
  ],
  rules: {
    'comma-dangle': 0,
    'no-underscore-dangle': 0,
    'no-param-reassign': 0,
    'no-return-assign': 0,
    'camelcase': 0,
    'import/extensions': 0,
    '@typescript-eslint/no-redeclare': 0,
  },
  settings: {
    'import/parsers': {
      '@typescript-eslint/parser': [
        '.ts',
        '.tsx',
      ],
    },
    'import/resolver': {
      'typescript': {},
    },
  },
};
