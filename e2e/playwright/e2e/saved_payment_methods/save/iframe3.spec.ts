import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, iframe3Success } from '../../../support/command'

test.describe('Saves Payment Method during iFrame 3.0 payment', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([['create', 'user']])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()
    await page.getByRole('switch', { name: 'Save card information for future payments' }).check();

    await iframe3Success(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()

    const espagoClientNumber = await appEval('SavedPaymentMethod.last.espago_client_id')
    await page.goto('/account')
    await page.getByRole('link', { name: 'Saved Payment Methods' }).click();
    await page.getByRole('link', { name: 'Saved Payment Method Details' }).click();
    await expect(page.getByText(`Espago Client ID: ${espagoClientNumber}`)).toBeVisible();
  })
})
