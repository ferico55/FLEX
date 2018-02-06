
# Warn when PR size is large
bigPRThreshold = 600

if git.modified_files.count + git.added_files.count > bigPRThreshold
  warn('Big PR : Pull Request size seems relatively large. If Pull Request contains multiple changes, split each into separate PR will helps faster, easier review.')
end

importantFilePatterns = [
	'AppDelegate.m',
	'UserAuthentificationManager.m',
	'MainViewController.m',
	'Podfile',
	'NetworkProvider.swift',
	'TKPDHmac.m',
	'TokopediaNetworkManager.m',
	'TKPDSecureStorage.m',
]

git.modified_files.each do | modified_file |
  path_is_important = importantFilePatterns.any? { | pattern | pattern.end_with? modified_file }
  warn(':exclamation: Changes were made to' + modified_file +', code reviewers check thoroughly') if path_is_important
end

swiftlint.lint_files inline_mode: true
