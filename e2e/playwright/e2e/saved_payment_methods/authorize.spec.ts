import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { login, createSavedPaymentMethod } from '../../support/command'


test.describe('Authorize Saved Payment Method', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([['create', 'user']])
    await login(page)
  })

  test('success', async ({ page }) => {
    await createSavedPaymentMethod(page)

    const espagoClientNumber = await appEval('SavedPaymentMethod.last.espago_client_id')
    await page.goto('/account')
    await page.getByRole('link', { name: 'Saved Payment Methods' }).click();
    await page.getByRole('link', { name: 'Saved Payment Method Details' }).click();
    await expect(page.getByText(`Espago Client ID: ${espagoClientNumber}`)).toBeVisible();

    await page.getByRole('link', { name: 'Authorize' }).click();
    await page.getByRole('button', { name: 'Authorize' }).click();
    await expect(page.getByText('Authorization success!')).toBeVisible();
  })

})
