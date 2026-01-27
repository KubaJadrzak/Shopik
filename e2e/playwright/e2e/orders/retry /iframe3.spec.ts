import { test, expect } from '@playwright/test'
import { app, appFactories, appEval } from '../../../support/on-rails'
import {  iframe3Fail, iframe3Success, login } from '../../../support/command'

test.describe('Order Retry with iFrame 3.0', () => {
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

    await iframe3Success(page)

    await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

  test('fail', async ({ page }) => {
    const orderNumber = await appEval('Order.last.uuid')

    await page.goto(`/orders/${orderNumber}`)
    await page.getByText('Retry Payment').click()

    await iframe3Fail(page)

    await expect(page.getByText('Payment rejected!')).toBeVisible({ timeout: 20_000 })
    await expect(page.getByText(orderNumber)).toBeVisible()
  })

})
