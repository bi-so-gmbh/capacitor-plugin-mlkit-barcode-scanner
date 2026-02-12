module.exports = {
  ...require('@ionic/prettier-config'),
  overrides: [
    {
      files: ["*.ts", "*.js"],
      options: {
        "semi": false
      }
    }
  ]
}
