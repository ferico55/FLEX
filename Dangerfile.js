// Removed import
import fs from 'fs'
import lodash from 'lodash'

var errorCount = 0;

// Warn when PR size is large
var bigPRThreshold = 600;

if (danger.github.pr.changed_files > bigPRThreshold) {
  warn('Big PR (' + ++errorCount + ')');
  markdown('> (' + errorCount + ') : Pull Request size seems relatively large. If Pull Request contains multiple changes, split each into separate PR will helps faster, easier review.');
}


const appDelegateFiles = danger.git.modified_files.filter(path => path.startsWith('ios/Tokopedia/AppDelegate')).length > 0
const userAuthFiles = danger.git.modified_files.filter(path => path.startsWith('ios/Tokopedia/UserAuthentificationManager')).length > 0
const mainVCFiles = danger.git.modified_files.filter(path => path.startsWith('ios/Tokopedia/MainViewController')).length > 0

if(appDelegateFiles) {
  	warn(":exclamation: Changes were made in AppDelegate.[h/m]. Please check thoroughly!")
}

if(userAuthFiles) {
  	warn(":exclamation: Changes were made in UserAuthenticationManager.[h/m]. Please check thoroughly!")
}

if(mainVCFiles) {
	warn(":exclamation: Changes were made in MainViewController.[h/m]. Please check thoroughly!")
}

const labels = danger.github.issue.labels.map(label => label.name)
const _ = require('lodash')

if(!_.includes(labels, 'retro-checked')) {
	warn("You have not checked your PR, please review your own PR codes and include label retro-checked once you done")
}
