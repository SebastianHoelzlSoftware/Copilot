const plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/copilot_web/live/**/*.ex',
    '../lib/copilot_web/components/**/*.ex'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(function({addVariant}) {
      addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])
      addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])
      addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])
      addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &'])
    })
  ]
}
