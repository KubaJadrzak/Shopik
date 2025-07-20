import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, oneTimeFail, oneTimeSuccess, payWithSavedCard } from '../../../support/command'

test.describe('Order Purchase with Saved Card', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')

    const [user] = await appFactories([
      ['create', 'user'],
    ])

    await appFactories([
      ['create', 'product', { title: 'First Product' }],
      ['create', 'product', { title: 'Second Product' }],
      ['create', 'client', 'primary', 'real',  { 'user_id': user.id }],
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

    await payWithSavedCard(page)

    await oneTimeSuccess(page)

    const orderNumber = await appEval('Order.last.order_number')
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

    await payWithSavedCard(page)

    await oneTimeFail(page)

    const orderNumber = await appEval('Order.last.order_number')
    await expect(page.getByText('Payment failed!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

})
