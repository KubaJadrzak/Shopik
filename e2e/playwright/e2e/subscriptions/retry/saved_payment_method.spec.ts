import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, iframeFail, iframeSuccess, withSavedPaymentMethod } from '../../../support/command'

test.describe('Subscription Retry with Saved Card', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([
      ['create', 'user', 'with_subscription', 'with_saved_payment_method'],
    ])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('link', { name: 'Subscriptions' }).click();
    await page.getByRole('link', { name: 'Subscription Details' }).click();
    await page.getByRole('button', { name: 'Retry Payment' }).click();

    withSavedPaymentMethod(page)

    iframeSuccess(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('link', { name: 'Subscriptions' }).click();
    await page.getByRole('link', { name: 'Subscription Details' }).click();
    await page.getByRole('button', { name: 'Retry Payment' }).click();

    withSavedPaymentMethod(page)

    iframeFail(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment rejected!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

})
