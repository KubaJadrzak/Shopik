import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, oneTimeFail, oneTimeSuccess, payWithSavedCard } from '../../../support/command'

test.describe('Subscription Extension with Saved Card', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    const [user] = await appFactories([
      ['create', 'user'],
    ])
    await appFactories([
      ['create', 'client', 'primary', 'real',  { 'user_id': user.id }],
    ])
    const [subscription] = await appFactories([
      ['create', 'subscription', { 'user_id': user.id }],
    ])
    await appFactories([
      ['create', 'payment', 'for_subscription', {
        'payable_id': subscription.id,
        'payable_type': 'Subscription',
        state: 'executed',
      }],
    ])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/subscriptions/1')
    await page.getByRole('button', { name: 'Extend Subscription' }).click()

    payWithSavedCard(page)

    oneTimeSuccess(page)

    const subscriptionNumber = await appEval('Subscription.last.subscription_number')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/subscriptions/1')
    await page.getByRole('button', { name: 'Extend Subscription' }).click()

    payWithSavedCard(page)

    oneTimeFail(page)

    const subscriptionNumber = await appEval('Subscription.last.subscription_number')
    await expect(page.getByText('Payment failed!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

})
