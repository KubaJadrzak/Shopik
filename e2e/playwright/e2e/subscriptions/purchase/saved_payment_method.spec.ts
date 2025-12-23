import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, iframeFail, iframeSuccess, withSavedPaymentMethod } from '../../../support/command'

test.describe('Subscription Purchase with Saved Payment Method', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')

    await appFactories([
      ['create', 'user', 'with_saved_payment_method'],
      ['create', 'product', { title: 'First Product' }],
      ['create', 'product', { title: 'Second Product' }],
    ])

    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    withSavedPaymentMethod(page)

    iframeSuccess(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    withSavedPaymentMethod(page)

    iframeFail(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment rejected!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

})
