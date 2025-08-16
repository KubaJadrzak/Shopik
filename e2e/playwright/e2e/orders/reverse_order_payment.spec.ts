import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../support/on-rails'
import { fillCardIframe, login, oneTimeSuccess } from '../../support/command'

test.describe('Reverse Order Payment', () => {
  let user: any
  test.beforeEach(async ({ page }) => {
    await app('clean')
    ;[user] = await appFactories([['create', 'user']])
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

    await fillCardIframe(page)

    await oneTimeSuccess(page)

    const orderNumber = await appEval('Order.last.order_number')
    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()

    await appEval(`Espago::UpdatePaymentStatusJob.perform_now(${user.id})`)
    await page.getByText('Cancel Order').click()
    await expect(page.getByText('Payment Reversed')).toBeVisible()
  })

})
