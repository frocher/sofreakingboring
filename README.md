## SoFreakingBoring

### What is SoFreakingBoring ?

SoFreakingBoring is a free and simple project management and time tracking application. It allows you to easily create your own projects and tasks, invite people and start working together.

![Project Dashboard](https://cloud.githubusercontent.com/assets/7987747/4908740/147eacae-646d-11e4-9971-9ebe095588fe.png)

### Requirements

* Ruby 2.0+
* MySQL for production

### Installation

Before starting SoFreakingBoring you need to follow these steps:

* migrate database with 'rake db:migrate'
* start in development mode with 'rails s'

The Whenever gem is used for cron jobs. To make it work:
* Enter 'whenever' to see what would be added to your cron tab
* Enter 'whenever -w' to add jobs to your crontab.


Note: SoFreakingBoring works on Linux and Mac OS X. It has not been tested on Windows and the whenever should not work. If you work on Windows you should consider [Vagrant](https://www.vagrantup.com/).

## Configuration

This project uses the following environment variables.

### Mandatory configuration

| Name  | Default Value | Description  |
| ----- | ------------- | ------------ |
| DEVISE_SECRET_KEY | none | You must generate a Devise key
| RAILS_ENV | development | Don't forget to switch it to production |
| PORT | 3000 | Puma server port |
| SECRET_TOKEN | none | Rails needs a secret token |


### MySQL Configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| DB_HOST | localhost | Database host server |
| DB_NAME | sofreaking | Database name |
| DB_PASSWORD | &nbsp; | User password |
| DB_PORT | 3306 | Database port |
| DB_USERNAME | root | User name used to log in |

### External services and mail configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| GOOGLE_ANALYTICS_KEY | none | if you want to track usage statistics |
| GRAVATAR_HTTPS | false | Must be true if https is used |

### OAuth Configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| FACEBOOK_KEY | none | facebook key for omniauth |
| FACEBOOK_SECRET | none | facebook secret for omniauth |
| GITHUB_KEY | none | github key for omniauth |
| GITHUB_SECRET | none | github secret for omniauth |
| GOOGLE_KEY | none | google key for omniauth |
| GOOGLE_SECRET | none | google secret for omniauth |
