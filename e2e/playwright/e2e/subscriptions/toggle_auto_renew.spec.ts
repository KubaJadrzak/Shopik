import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { login } from '../../support/command'

test.describe('Toggle Auto Renew', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([
      ['create', 'user'],
    ])
    await login(page)
  })
  test.describe('when user does not have Primary Saved Payment Method', () => {
    test('display instructions', async({ page }) => {
      const user = await appEval('User.last')
      await appFactories([['create', 'subscription', { user_id: user.id, state: 'Active' }]])

      await page.goto('/account')
      await page.getByRole('link', { name: 'Subscriptions' }).click();
      await expect(page.getByLabel('Primary Saved Payment Method and previously purchased Subscription is required to enable Auto-Renew functionality')).toBeVisible();
    })
  })

  test.describe('when user does not have a previous Subscription', () => {
    test('display instructions', async({ page }) => {
      const user = await appEval('User.last')
      await appFactories([['create', 'saved_payment_method', { user_id: user.id, state: 'MIT Verified', primary: true }]])

      await page.goto('/account')
      await page.getByRole('link', { name: 'Subscriptions' }).click();
      await expect(page.getByLabel('Primary Saved Payment Method and previously purchased Subscription is required to enable Auto-Renew functionality')).toBeVisible();
    })
  })

  test.describe('when user does have both previous subscription and Primary Saved Payment Method', () => {
    test('toggle auto-renew', async({ page }) => {
      const user = await appEval('User.last')
      await appFactories([['create', 'subscription', { user_id: user.id, state: 'Active' }]])
      await appFactories([['create', 'saved_payment_method', { user_id: user.id, state: 'MIT Verified', primary: true }]])

      await page.goto('/account')
      await page.getByRole('link', { name: 'Subscriptions' }).click();
      await expect(page.getByText('Your Subscriptions')).toBeVisible();
      await expect(page.getByLabel('Primary Saved Payment Method and previously purchased Subscription is required to enable Auto-Renew functionality')).toBeHidden();
    })
  })

})
