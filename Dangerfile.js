// Removed import
const fs = require('fs')
const lodash = require('lodash')

var errorCount = 0;

// Warn when PR size is large
var bigPRThreshold = 600;

if (danger.github.pr.changed_files > bigPRThreshold) {
  warn('Big PR (' + ++errorCount + ')');
  markdown('> (' + errorCount + ') : Pull Request size seems relatively large. If Pull Request contains multiple changes, split each into separate PR will helps faster, easier review.');
}

const importantFilePatterns = [
	'AppDelegate.m',
	'UserAuthentificationManager.m',
	'MainViewController.m',
	'Podfile',
	'package.json',
	'NetworkProvider.swift',
	'TKPDHmac.m',
	'TokopediaNetworkManager.m',
	'TKPDSecureStorage.m',
];

danger.git.modified_files.forEach(path => {
	const pathIsImportant = importantFilePatterns.some(pattern => path.endsWith(pattern))
	if (pathIsImportant) {
		warn(`:exclamation: Changes were made to ${path}, code reviewers check thoroughly`)
	}
})

const labels = danger.github.issue.labels.map(label => label.name)
const _ = require('lodash')

if(!_.includes(labels, 'retro-checked')) {
	warn("You have not checked your PR, please review your own PR codes and include label retro-checked once you done")
}
