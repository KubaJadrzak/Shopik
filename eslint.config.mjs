import globals from 'globals'
import pluginJs from '@eslint/js'
import tseslint from 'typescript-eslint'
import stylistic from '@stylistic/eslint-plugin'
import playwright from 'eslint-plugin-playwright'

export default [
  {
    ...playwright.configs['flat/recommended'],
    files: ['e2e/playwright/**/*.{js,mjs,cjs,ts}'],
    rules: {
      ...playwright.configs['flat/recommended'].rules,
    },
  },
  ...tseslint.configs.recommended.map((config) => ({
    ...config,
    files: ['**/*.{js,mjs,cjs,ts,tsx}'],
  })),
  {
    ...pluginJs.configs.recommended,
    files: ['**/*.{js,mjs,cjs,ts,tsx}'],
  },
  {
    files: ['**/*.{js,mjs,cjs,ts,tsx}'],
    ignores: ["app/javascript/controllers/index.js"],
    plugins: {
      '@stylistic': stylistic,
    },
    languageOptions: {
      globals: globals.browser,
    },
    rules: {
      // Built-in ESLint rules
      'default-param-last': ['warn'],
      'eqeqeq': ['warn', 'smart'],
      'no-constructor-return': ['error'],
      'no-empty': ['warn'],
      'no-unused-vars': ['warn', { 'args': 'none' }],
      'no-lonely-if': ['warn'],
      'no-nested-ternary': ['error'],
      'no-shadow': ['error'],
      'no-undef': ['off'],
      'no-undef-init': ['error'],
      'no-unneeded-ternary': ['warn'],
      'no-useless-return': ['warn'],
      'no-var': ['error'],
      'default-case-last': ['warn'],
      'no-else-return': ['warn'],
      'no-duplicate-imports': ['warn'],
      'camelcase': [
        'error',
        {
          'properties': 'always',
          'ignoreDestructuring': true,
        },
      ],
      'object-shorthand': ['warn', 'always'],
      'operator-assignment': ['warn', 'always'],
      'prefer-arrow-callback': ['error'],
      'prefer-exponentiation-operator': ['warn'],
      'prefer-template': ['warn'],
      'yoda': ['warn'],
      'prefer-const': ['off'],

      '@stylistic/indent': ['warn', 2],
      '@stylistic/quotes': ['warn', 'single'],
      '@stylistic/semi': ['error', 'never'],
      '@stylistic/comma-dangle': ['warn', 'always-multiline'],
      '@stylistic/object-curly-spacing': ['warn', 'always'],
      '@stylistic/array-bracket-spacing': ['warn', 'never'],
      '@stylistic/space-before-blocks': ['warn'],
      '@stylistic/keyword-spacing': ['warn'],
      '@stylistic/space-infix-ops': ['error'],
      '@stylistic/no-trailing-spaces': ['warn'],
      '@stylistic/eol-last': ['warn'],
      '@stylistic/no-multiple-empty-lines': ['warn', { 'max': 2 }],
      '@stylistic/brace-style': ['warn', '1tbs', { 'allowSingleLine': true }],
    },
  },
]