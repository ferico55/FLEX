echo 'Copying post checkout scripts'
cp scripts/post-checkout .git/hooks/

echo 'Installing node'
brew install node

echo 'Installing watchman'
brew install watchman

echo 'Installing yarn'
brew install yarn

echo 'Installing react native cli'
sudo npm install -g react-native-cli

echo 'Installing node modules'
yarn install
