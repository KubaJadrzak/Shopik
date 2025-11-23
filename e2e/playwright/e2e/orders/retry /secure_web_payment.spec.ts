import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { login, swpSuccess, swpFail } from '../../../support/command'

test.describe('Order Retry with Secure Web Page', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    const [user] = await appFactories([
      ['create', 'user'],
    ])
    await appFactories([
      ['create', 'product', { title: 'First Product' }],
      ['create', 'product', { title: 'Second Product' }],
      ['create', 'order', { 'user_id': user.id }],
    ])
    await login(page)
  })

  test('success', async ({ page }) => {
    await page.goto('/orders/1')
    await page.getByText('Retry Payment').click()

    await swpSuccess(page)

    const orderNumber = await appEval('Order.last.uuid')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    await page.goto('/orders/1')
    await page.getByText('Retry Payment').click()

    await swpFail(page)

    const orderNumber = await appEval('Order.last.uuid')
    await expect(page.getByText('Payment failed!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })
})
