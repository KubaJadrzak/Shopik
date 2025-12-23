import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { login } from '../../support/command'

test.describe('Toggle Primary Saved Payment Method', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([['create', 'user', 'with_saved_payment_method']])
    await login(page)
  })
  test.describe('when Saved Payment Method is not MIT Verified', () => {
    test('display instructions', async({ page }) => {

    await appEval('SavedPaymentMethod.last.update(state: "CIT Verified")')
    const savedPaymentMethodNumber = await appEval('SavedPaymentMethod.last.uuid')

    await page.goto(`/saved_payment_methods/${savedPaymentMethodNumber}`)

    await expect(page.getByLabel('You need to Authorize your Saved Payment Method in order to make it Primary')).toBeVisible();
    })
  })

  test.describe('when Saved Payment Method is MIT Verified', () => {
    test('toggle primary', async({ page }) => {
    await appEval('SavedPaymentMethod.last.update(state: "MIT Verified")')
    const savedPaymentMethodNumber = await appEval('SavedPaymentMethod.last.uuid')

    await page.goto(`/saved_payment_methods/${savedPaymentMethodNumber}`)
    await expect(page.getByLabel('You need to Authorize your Saved Payment Method in order to make it Primary')).toBeHidden();
    await page.getByRole('switch').check();
    })
  })


})
