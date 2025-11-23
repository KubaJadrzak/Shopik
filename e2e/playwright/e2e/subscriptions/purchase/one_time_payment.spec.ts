import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { fillCardIframe, login, oneTimeFail, oneTimeSuccess } from '../../../support/command'

test.describe('Subscription Purchase with One Time Payment', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([['create', 'user']])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    await fillCardIframe(page)

    await oneTimeSuccess(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    await fillCardIframe(page)

    await oneTimeFail(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment failed!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

})
