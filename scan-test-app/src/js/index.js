/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import { Capacitor } from '@capacitor/core'
import { MlKitBarcodeScanner } from '@biso_gmbh/capacitor-plugin-ml-kit-barcode-scanner'

const defaultOptions = {
  barcodeFormats: {
    Aztec: true,
    CodaBar: true,
    Code39: true,
    Code93: true,
    Code128: true,
    DataMatrix: true,
    EAN8: true,
    EAN13: true,
    ITF: true,
    PDF417: true,
    QRCode: true,
    UPCA: true,
    UPCE: true
  },
  beepOnSuccess: false,
  vibrateOnSuccess: false,
  detectorSize: 0.9,
  detectorAspectRatio: '5:1',
  drawFocusRect: true,
  focusRectColor: '#FFFFFF',
  focusRectBorderRadius: 10,
  focusRectBorderThickness: 5,
  drawFocusLine: false,
  focusLineColor: '#ff2d37',
  focusLineThickness: 2,
  drawFocusBackground: false,
  focusBackgroundColor: '#66FFFFFF',
  stableThreshold: 5,
  debugOverlay: false,
  ignoreRotatedBarcodes: false
}

init()

function onSuccess(result) {
  const htmlStrings = result.barcodes
    .map(
      barcode => `
    <div class="log_item">
      <strong>${barcode.value}</strong> (${barcode.format}/${barcode.type} - ${barcode.distanceToCenter})
    </div>
  `
    )
    .join('')

  document.getElementById('output').insertAdjacentHTML('afterbegin', htmlStrings)
}

function onFail(result) {
  const node = document.createElement('div')
  node.className = 'log_item'
  node.textContent = `${result}`

  document.getElementById('output').prepend(node)
}

function optionsFromHTML() {
  let options = {}
  for (const key in defaultOptions) {
    const element = document.getElementById(key)
    if (element) {
      if (element.tagName === 'INPUT' && element.type === 'checkbox') {
        options[key] = element.checked
      } else {
        options[key] = element.value
      }
    }
  }

  options.barcodeFormats = {}
  for (const format in defaultOptions.barcodeFormats) {
    const element = document.getElementById(format)

    if (element) {
      options.barcodeFormats[format] = element.checked
    }
  }

  return options
}

function optionsToHTML(options = defaultOptions) {
  for (const key in options) {
    const element = document.getElementById(key)

    if (element) {
      if (element.tagName === 'INPUT' && element.type === 'range') {
        element.oninput = e => {
          e.target.nextElementSibling.value = e.target.value
        }
        element.nextElementSibling.value = options[key]
        element.value = options[key]
      } else if (element.tagName === 'INPUT' && element.type === 'checkbox') {
        element.checked = options[key]
      } else {
        element.value = options[key]
      }
    }
  }

  for (const format in options.barcodeFormats) {
    const element = document.getElementById(format)

    if (element) {
      element.checked = options.barcodeFormats[format]
    }
  }
}

async function scan() {
  console.log('scan button clicked')
  const options = optionsFromHTML()

  try {
    const result = await MlKitBarcodeScanner.scan(options)

    console.log('result', result)
    onSuccess(result)
  } catch (error) {
    console.log(error)
    onFail(error)
  }
}

function clearLog() {
  document.getElementById('output').innerHTML = ''
}

function setAllBarcodeFormats(checked) {
  const options = optionsFromHTML()

  for (const format in options.barcodeFormats) {
    options.barcodeFormats[format] = checked
  }

  optionsToHTML(options)
}

function init(options = defaultOptions) {
  console.log('Running capacitor-' + Capacitor.getPlatform())
  document.getElementById('scan').onclick = scan
  document.getElementById('clearLog').onclick = clearLog
  document.getElementById('selectAllBarcodeFormats').onclick = () => setAllBarcodeFormats(true)
  document.getElementById('deselectAllBarcodeFormats').onclick = () => setAllBarcodeFormats(false)

  optionsToHTML(options)
}
