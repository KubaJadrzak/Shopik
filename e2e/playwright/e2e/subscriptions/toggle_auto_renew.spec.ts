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
      ['create', 'subscription', { 'user_id': user.id }],
      ['create', 'saved_payment_methods', 'primary', 'real',  { 'user_id': user.id }],
    ])
    await login(page)
  })
  test.describe('when user doesnt have primary payment method', () => {
    test('shows button to select primary payment method', async({ page }) => {
      await appEval('Saved_Payment_Method.last.destroy')
      await page.goto('/subscriptions/1')
      await expect(page.getByText('Select Payment Method')).toBeVisible()
    })
  })

  test.describe('when subscription is not active', () => {
    test('toggle button is disabled', async({ page }) => {
      await appEval('Subscription.last.update_columns(status: \'Payment Failed\')')
      await page.goto('/subscriptions/1')
      await expect(page.locator('body')).toMatchAriaSnapshot('- checkbox [disabled]')
    })
  })

  test.describe('when subscription is active and user has primary payment method', () => {
    test('toggle button is enabled', async({ page }) => {
      await page.goto('/subscriptions/1')
      await expect(page.locator('body')).toMatchAriaSnapshot('- checkbox')
      await page.locator('#auto_renew').check()
    })
  })

})
