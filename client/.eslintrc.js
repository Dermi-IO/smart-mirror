module.exports = {
  extends: ['airbnb-typescript/base', 'plugin:storybook/recommended'],
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
  extends: 'airbnb-typescript/base',
  plugins: [
    'import',
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
