This project is a fork of the original redmine_milestones from   
https://github.com/k41n/redmine_milestones 
I have made plugin compatible with Redmine 2.2.0.stable.11055 
all prototype dependent javascript statements were removed.. 


redmine_milestones
==================

This plugin adds milestone entity in Redmine (http://www.redmine.org/).

Milestones can be created either inside versions or connected to project itself.

Milestones have actual/planned start and due dates. Actual dates are calculated based on
issues connected to milestones.

Milestones can be hierarchically included one into other, thus making possible to create aggregate milestones, joining
submilestones and issues from different projects.

Developed in 2012 by RedmineCRM (http://redminecrm.com)

Installation
============

This version has been tested with redmine branches 1.3 and 1.4 as far as with MySQL and PostgresSQL RDBMS.

Clone repository into vendor/plugins:

$ cd <your redmine root directory>
$ git clone git://github.com/k41n/redmine_milestones.git vendor/plugin/redmine_milestones

Run migrations

Before this step make sure there is no table named milestones in your database.

$ RAILS_ENV=production rake db:migrate:plugin NAME=redmine_milestones

Login into Redmine, enable plugin on project plugins page and enjoy.

Warning!

If you are updating plugin from earlier version make sure you have cleared your browser cache as far
some cases reported when deprecated javascript gets into cache and leads to problems.

Credits
=======

This plugin was created with kind support and has been fully sponsored by Mellanox (http://mellanox.com/)



