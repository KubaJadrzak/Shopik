import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, swpFail, swpSuccess } from '../../../support/command'

// these tests depend entirely on back requests and will not make sense while running on localhost

test.describe('Saves Payment Method during Secure Web Payment', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([['create', 'user']])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()
    await page.getByRole('checkbox', { name: 'Save card information for' }).check()

    await swpSuccess(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/account')
    await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
    await page.getByRole('button', { name: 'Go to Payment' }).click()
    await page.getByRole('checkbox', { name: 'Save card information for' }).check()

    await swpFail(page)

    const subscriptionNumber = await appEval('Subscription.last.uuid')
    await expect(page.getByText('Payment failed!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(subscriptionNumber)).toBeVisible()
  })

})
