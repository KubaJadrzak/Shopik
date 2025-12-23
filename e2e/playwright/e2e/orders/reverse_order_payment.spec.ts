import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { fillCardIframe, login, iframeSuccess } from '../../support/command'

test.describe('Reverse Order Payment', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([
      ['create', 'user'],
      ['create', 'product', { title: 'First Product' }],
      ['create', 'product', { title: 'Second Product' }],
    ])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/')
    await page.getByText('Add to Cart').first().click()
    await page.getByText('Add to Cart').nth(1).click()
    await page.getByAltText('Cart').click()
    await expect(page.getByText('Your Cart')).toBeVisible()
    await expect(page.getByText('First Product')).toBeVisible()
    await expect(page.getByText('Second Product')).toBeVisible()

    await page.getByText('Place Order').click()
    await page.getByLabel('Shipping Address').fill('Shipping Address')
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    await fillCardIframe(page)

    await iframeSuccess(page)

    const orderNumber = await appEval('Order.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()

    await appEval(`::UpdatePaymentStatusJob.perform_now`)
    await page.getByText('Cancel Order').click()
    await page.getByRole('button', { name: 'Cancel Order' }).click()
    await expect(page.getByText('Cancellation successful!', { exact: true })).toBeVisible()
  })

})
