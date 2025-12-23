import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import { fillCardIframe, login, iframeFail, iframeSuccess } from '../../../support/command'

test.describe('Order Retry with One Time Payment', () => {
  test.beforeEach(async ({ page }) => {
    await app('clean')
    await appFactories([
      ['create', 'user', 'with_order'],
    ])

    await login(page)
  })

  test('success', async ({ page }) => {
    const orderNumber = await appEval('Order.last.uuid')

    await page.goto(`/orders/${orderNumber}`)
    await page.getByText('Retry Payment').click()

    await fillCardIframe(page)

    await iframeSuccess(page)

    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    const orderNumber = await appEval('Order.last.uuid')

    await page.goto(`/orders/${orderNumber}`)
    await page.getByText('Retry Payment').click()


    await fillCardIframe(page)

    await iframeFail(page)

    await expect(page.getByText('Payment rejected!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

})
