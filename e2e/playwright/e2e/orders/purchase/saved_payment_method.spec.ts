import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, iframeFail, iframeSuccess, withSavedPaymentMethod } from '../../../support/command'

test.describe('Order Purchase with Saved Payment Method', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')

    await appFactories([
      ['create', 'user', 'with_cit_saved_payment_method'],
      ['create', 'product', { title: 'First Product' }],
      ['create', 'product', { title: 'Second Product' }],
    ])

    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/products')
    await page.getByText('Add to Cart').first().click()
    await page.getByText('Add to Cart').nth(1).click()
    await page.getByAltText('Cart').click()
    await expect(page.getByText('Your Cart')).toBeVisible()
    await expect(page.getByText('First Product')).toBeVisible()
    await expect(page.getByText('Second Product')).toBeVisible()

    await page.getByText('Place Order').click()
    await page.getByLabel('Shipping Address').fill('Shipping Address')
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    await withSavedPaymentMethod(page)

    await iframeSuccess(page)

    const orderNumber = await appEval('Order.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/products')
    await page.getByText('Add to Cart').first().click()
    await page.getByText('Add to Cart').nth(1).click()
    await page.getByAltText('Cart').click()
    await expect(page.getByText('Your Cart')).toBeVisible()
    await expect(page.getByText('First Product')).toBeVisible()
    await expect(page.getByText('Second Product')).toBeVisible()

    await page.getByText('Place Order').click()
    await page.getByLabel('Shipping Address').fill('Shipping Address')
    await page.getByRole('button', { name: 'Go to Payment' }).click()

    await withSavedPaymentMethod(page)

    await iframeFail(page)

    const orderNumber = await appEval('Order.last.uuid')
    await expect(page.getByText('Payment rejected!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

})
