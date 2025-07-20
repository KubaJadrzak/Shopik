import { Page, expect } from '@playwright/test'

export async function login(page) {
  const baseURL =  'http://localhost:3001'
  try {
    const response = await page.request.post(`${baseURL}/sign_in_before_test`)
    if (!response.ok()) {
      throw new Error(`Login failed with status: ${response.status()}`)
    }
    console.log('Login successful')
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

export async function oneTimeSuccess(page: Page) {
  await page.waitForURL(/secure_web_page/)
  const secureFrame = page.frameLocator('iframe')
  await secureFrame.getByText('3D-Secure 2 Payment - simulation').waitFor()
  await secureFrame.locator('#confirm-btn').click()
}

export async function oneTimeFail(page: Page) {
  await page.waitForURL(/secure_web_page/)
  const secureFrame = page.frameLocator('iframe')
  await secureFrame.getByText('3D-Secure 2 Payment - simulation').waitFor()
  await secureFrame.locator('#reject-btn').click()
}

export async function fillCardIframe(page: Page) {
  await expect(page.getByText('Choose Payment Method')).toBeVisible()
  await page.getByLabel('One-time Payment').check()
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

export async function payWithSavedCard(page: Page) {
  await expect(page.getByText('Choose Payment Method')).toBeVisible()
  await page.getByLabel('•••• 1234').check()
  // eslint-disable-next-line playwright/no-wait-for-timeout
  await page.waitForTimeout(1000)
  await page.click('#pay_btn')

}
