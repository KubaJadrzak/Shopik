import { test, expect } from '@playwright/test'
import { app, appFactories } from '../../support/on-rails'
import { login } from '../../support/command'


test.describe('Order Retry with Saved Card', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')

    const [user] = await appFactories([
      ['create', 'user'],
    ])

    await appFactories([
      ['create', 'saved_payment_methods', 'real',  { 'user_id': user.id }],
    ])

    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/espago/clients/1')
    await page.getByRole('link', { name: 'Verify' }).click()
    await page.getByRole('button', { name: 'Pay' }).click()

    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
  })

})
