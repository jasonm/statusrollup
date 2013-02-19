Overview
================

There are several tools that take advantage of the GitHub Commit Status API
to attach a status to your GitHub projects' commits and pull requests.

Unfortunately there is a last-one-wins situation where multiple tools
cannot be effectively used on the same project.

StatusRollup aims to fix this by aggregating commit statuses from other tools:

![Status rolled up](https://f.cloud.github.com/assets/1031/170562/74a70024-7a70-11e2-9812-8dca9e88c488.jpg)

![Many statuses revealed](https://f.cloud.github.com/assets/1031/170563/76a66d60-7a70-11e2-96db-4048e8494c50.jpg)


This project is a work-in-progress.  Any and all feedback is welcome!

It currently works, but could use UI and functionality improvement.  Find
such discussion in [GitHub issues](https://github.com/jasonm/statusrollup/issues).

Build status
------------

[![Build Status](https://secure.travis-ci.org/jasonm/statusrollup.png)](http://travis-ci.org/jasonm/statusrollup)

Development
================

Prerequisites
----------------

Register a new app at GitHub to get an OAuth key and secret:

https://github.com/settings/applications/new

Set up a .env file with your GITHUB_KEY and GITHUB_SECRET.
You can also specify an HTTP port for local foreman:

    GITHUB_KEY=abc123
    GITHUB_SECRET=234897239872394832478
    PORT=3000

This file is .gitignored so it's private.

We use the `dotenv` gem to provide these variables to the test environment as
well.

JavaScript acceptance tests use
[poltergeist](https://github.com/jonleighton/poltergeist) which requires
installing [PhantomJS](http://phantomjs.org).  Follow the PhantomJS
installation instructions on the [poltergeist
README](https://github.com/jonleighton/poltergeist).

Getting set up
----------------

Install gems and initialize databases:

    bundle
    rake db:create db:migrate db:test:prepare

Run the tests to make sure things are working:

    rake

Running the app
----------------

Run with Foreman if you like:

    foreman start

Or as normal (.env is loaded by `dotenv` gem):

    rails server
    rails console

Coverage
----------------

Use SimpleCov to build code coverage:

    COVERAGE=true rake

LiveReload
----------------

When working on display-heavy features, [LiveReload](http://livereload.com/)
saves valuable keystrokes and time.  We use
[guard-livereload](https://github.com/guard/guard-livereload) to watch
templates and assets and reload when they change.

To take advantage of this:

* Install a [LiveReload browser extension](http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions-)
* Run `guard` on the command line.

LocalTunnel
------------------

As part of the app, we sign up to receive GitHub webhooks (HTTP requests to
`/repo_hook`) to be notified when stuff happens to repos we care about.  (In
particular, we want to know about new status updates so we can aggregate them.)

When you're developing locally, GitHub can't send webhook events
to you at `localhost:3000`, so use [localtunnel](http://localtunnel.com) to get a
public proxy to `localhost`:

    $ START_LOCALTUNNEL=1 foreman start

This will create a new localtunnel via their API and cache the hostname into
`.localtunnel_host`.  When you create new `Agreement`s locally, this hostname
will be send to GitHub as the webhook receive endpoint.

If you kill your server and restart, you'd get a new host, and those webhook
endpoint URLs stored on GitHub need to be updated.  Currently there's no
automated fixup, but you can try to keep ahold of the previously cached
hostname with:

    $ READ_LOCALTUNNEL=1 foreman run rails console

Deployment
================
See DEPLOY.md for information on deploying.

License
================

See [LICENSE](https://github.com/jasonm/statusrollup/blob/master/LICENSE) for the project license.
