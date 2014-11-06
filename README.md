[![Build Status](https://travis-ci.org/frocher/sofreakingboring.svg?branch=master)](https://travis-ci.org/frocher/sofreakingboring)

## SoFreakingBoring

### What is SoFreakingBoring ?

SoFreakingBoring is a free and simple project management and time tracking application. It allows you to easily create your own projects and tasks, invite people and start working together.

![Project Dashboard](https://cloud.githubusercontent.com/assets/7987747/4908740/147eacae-646d-11e4-9971-9ebe095588fe.png)

You can use it online here : [www.sofreakingboring.com](https://www.sofreakingboring.com/).

### Requirements

* Ruby 2.0+
* MySQL for production

### Installation

Before starting SoFreakingBoring you need to follow this steps :

* copy database.yml.example to database.yml. 
* copy olb.yml.example to olb.yml.
* copy puma.rb.example to puma.rb
* adapt the three files to your environment
* migrate database with 'rake db:migrate'
* start in development mode with 'rails s'

The Whenever gem is used for cron jobs. To make it work :
* Enter 'whenever' to see what would be added to your cron tab
* Enter 'whenever -w' to add jobs to your crontab.


Note : SoFreakingBoring works on Linux and Mac OS X. It has not been tested on Windows and the whenever should not work. If you work on Windows you should consider [Vagrant](https://www.vagrantup.com/).


### Credits

I want to thank :

* [GitLab](https://gitlab.com/) : great open source project and more than a source of inspiration.
* [Handsontable](http://handsontable.com/) : minimalist Excel-like data grid editor.
* [Gratisography](http://gratisography.com/) : free high-resolution pictures that can be used on personal and commercial projects.
