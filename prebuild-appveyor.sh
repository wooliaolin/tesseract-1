cp ./src/tesseract/appveyor.yml .

# Clone Submodules
sed -i '.original' 's/install:/install:\
  - git submodule update --init --recursive/g' appveyor.yml

# Setup Tesseract-Path
sed -i '.original' 's/before_build:/before_build:\
  - cd src\\tesseract/g' appveyor.yml

# Setup Release Path
sed -i '.original' 's/path: build\\bin\\Release/path: src\\tesseract\\build\\bin\\Release/g' appveyor.yml

# Setup artifact name
sed -i '.original' 's/tesseract-$(APPVEYOR_BUILD_VERSION)/tesseract-$(PLATFORM)/g' appveyor.yml

rm appveyor.yml.original

echo "
deploy:
  provider: GitHub
  auth_token:
    secure: \"m2s33ZawUyxHN1gOUBC4vew87elqLNZMQVTNWnTXdZB746JuBNSRlzK2mSr6Oq4u\"
  draft: false
  prerelease: false
  on:
    appveyor_repo_tag: true
" >> appveyor.yml
