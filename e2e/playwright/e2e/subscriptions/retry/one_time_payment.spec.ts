import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { fillCardIframe, login, oneTimeFail, oneTimeSuccess } from '../../../support/command'

test.describe('Subscription Retry with One Time Payment', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    const [user] = await appFactories([
      ['create', 'user'],
    ])
    await appFactories([
      ['create', 'subscription', 'new', { 'user_id': user.id }],
    ])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Manage Subscription' }).click()
    await page.getByRole('button', { name: 'Retry Payment' }).click()

    await fillCardIframe(page)

    await oneTimeSuccess(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Manage Subscription' }).click()
    await page.getByRole('button', { name: 'Retry Payment' }).click()

    await fillCardIframe(page)

    await oneTimeFail(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment failed!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

})
