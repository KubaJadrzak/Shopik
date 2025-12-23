import { Page, expect } from '@playwright/test'
import { appEval } from '../support/on-rails'

export async function login(page: Page) {
  const baseURL =  'http://localhost:3001'
  try {
    const response = await page.request.post(`${baseURL}/sign_in_before_test`)
    if (!response.ok()) {
      throw new Error(`Login failed with status: ${response.status()}`)
    }
  } catch (error) {
    console.error('Login failed:', error)
    throw error
  }
}


export async function swpSuccess(page: Page) {
  await expect(page.getByText('Choose Payment Method')).toBeVisible()
  await page.getByLabel('Secure Web Page').check()
  // eslint-disable-next-line playwright/no-wait-for-timeout
  await page.waitForTimeout(1000)
  await page.click('#pay_btn')

  await page.waitForURL(/secure_web_page/)
  await page.locator('#test-cards-modal-btn').click()
  await page.getByText('0000 0002 0006').first().click()
  await page.click('#submit_payment')
  const secureFrame = page.frameLocator('iframe')
  await secureFrame.getByText('3D-Secure 2 Payment - simulation').waitFor()
  await secureFrame.locator('#confirm-btn').click()
  await page.getByText('Back to shop').click()
}

export async function swpFail(page: Page) {
  await expect(page.getByText('Choose Payment Method')).toBeVisible()
  await page.getByLabel('Secure Web Page').check()
  // eslint-disable-next-line playwright/no-wait-for-timeout
  await page.waitForTimeout(1000)
  await page.click('#pay_btn')

  await page.waitForURL(/secure_web_page/)
  await page.locator('#test-cards-modal-btn').click()
  await page.getByText('0000 0002 0006').first().click()
  await page.click('#submit_payment')
  const secureFrame = page.frameLocator('iframe')
  await secureFrame.getByText('3D-Secure 2 Payment - simulation').waitFor()
  await secureFrame.locator('#reject-btn').click()
  await page.getByText('Back to shop').click()
}

export async function iframeSuccess(page: Page) {
  await page.waitForURL(/secure_web_page/)
  const secureFrame = page.frameLocator('iframe')
  await secureFrame.getByText('3D-Secure 2 Payment - simulation').waitFor()
  await secureFrame.locator('#confirm-btn').click()
}

export async function iframeFail(page: Page) {
  await page.waitForURL(/secure_web_page/)
  const secureFrame = page.frameLocator('iframe')
  await secureFrame.getByText('3D-Secure 2 Payment - simulation').waitFor()
  await secureFrame.locator('#reject-btn').click()
}

export async function fillCardIframe(page: Page) {
  await expect(page.getByText('Choose Payment Method')).toBeVisible()
  await page.getByLabel('iFrame').check()
  // eslint-disable-next-line playwright/no-wait-for-timeout
  await page.waitForTimeout(1000)
  await page.click('#pay_btn')
  const iframe = page.frameLocator('iframe')
  await iframe.getByLabel('Imię').fill('Jan')
  await iframe.getByLabel('Nazwisko').fill('Kowalski')
  await iframe.getByLabel('Numer karty').fill('4012000000020006')
  await iframe.getByLabel('MM').fill('1')
  await iframe.getByLabel('RR').fill('30')
  await iframe.getByLabel('CVV').fill('123')
  await iframe.getByRole('button', { name: 'Pay' }).click()
}

export async function withSavedPaymentMethod(page: Page) {
  await expect(page.getByText('Choose Payment Method')).toBeVisible()
  await page.locator('#client').check();
  await page.waitForTimeout(1000)
  await page.click('#pay_btn')

}

export async function createSavedPaymentMethod(page: Page) {
  await page.goto('/account')
  await page.getByRole('button', { name: 'Subscribe to Membership' }).click()
  await page.getByRole('button', { name: 'Go to Payment' }).click()
  await page.getByRole('switch', { name: 'Save card information for future payments' }).check();

  await swpSuccess(page)

  const subscriptionNumber = await appEval('Subscription.last.uuid')
  await expect(page.getByText('Payment successful!')).toBeVisible({ timeout: 20_000 })
  await expect(page.getByText(subscriptionNumber)).toBeVisible()

  await appEval(`::UpdatePaymentStatusJob.perform_now`)
}
