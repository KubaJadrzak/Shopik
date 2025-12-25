import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { login, createSavedPaymentMethod } from '../../support/command'


test.describe('Delete Saved Payment Method', () => {
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

    await page.getByText('Delete').click()
    await expect(page.getByText('We have successfully deleted your Saved Payment Method!')).toBeVisible();
  })

})
