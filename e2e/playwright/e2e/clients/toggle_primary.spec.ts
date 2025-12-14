import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { login } from '../../support/command'

test.describe('Toggle Auto Renew', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    let [user] = await appFactories([
      ['create', 'user'],
    ])
    await appFactories([
      ['create', 'saved_payment_methods', { 'user_id': user.id }],
    ])
    await login(page)
  })
  test.describe('when payment method is not verified for auto-renew', () => {
    test('shows button to select primary payment method', async({ page }) => {
      await page.goto('espago/clients/1')
      await expect(page.getByText('Verification Required')).toBeVisible()
    })
  })

  test.describe('when payment method is verified for auto renew', () => {
    test('toggle button is enabled', async({ page }) => {
      await appEval('Saved_Payment_Method.last.update_columns(status: \'MIT\')')
      await page.goto('espago/clients/1')
      await expect(page.locator('body')).toMatchAriaSnapshot('- checkbox')
      await page.locator('#primary').check()
      await expect(page.getByRole('heading', { name: 'Primary', level: 5 })).toBeVisible()
    })
  })


})
