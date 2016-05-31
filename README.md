
# Lien Project

* [Requirements](Requirements)
* [Setup](Setup)
* [Testing](Testing)
* [Running](Running)
* [Deployment](Deployment)

## Requirements

* Rails
* NodeJS
* Third party packages:
  * Bower
  * browserify
  * watchify
  * karmajs
* Postgres

## Setup

1. Install rail
  * Full guide [here](http://installrails.com/steps/choose_os)
2. Install node [here](https://nodejs.org/en/download/)
3. Install postgres [here](https://launchschool.com/blog/how-to-install-postgresql-on-a-mac)
  * Create `test` database
  * Create `foo` database
4. Install third party dependencies
  * npm install -g watchify
  * npm install -g bower
  * npm install -g browserify
  * npm install -g babelify
  * npm install -g reactify
  * npm install -g coffeeify
  * npm install -g browserify-css
  * npm install
  * cd server && bundle install

## Testing

* Test javascript client
`karma start my.conf.js`

* Run server specs
`cd server && rake spec`

## Running

This project uses foreman to manage all run processes explained below

`foreman -f Procefileforman`

## Deployment
1. Run migrations
`heroku run rake db:migrate`

2. Push new version
```git push --force heroku `git subtree split --prefix server HEAD`:master```
