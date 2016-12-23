[![Code Climate](https://codeclimate.com/github/egoexpress/sifttter-redux-known/badges/gpa.svg)](https://codeclimate.com/github/egoexpress/sifttter-redux-known) [![Travis CI](https://travis-ci.org/egoexpress/sifttter-redux-known.svg?branch=master)](https://travis-ci.org/egoexpress/sifttter-redux-known)

Sifttter Redux Known Edition
============================

# Intro

The original [Siftter Redux](https://github.com/bachya/Sifttter-Redux) made by Aaron Bach is a modification 
of Craig Eley's [Sifttter](http://craigeley.com/post/72565974459/sifttter-an-ifttt-to-day-one-logger "Sifttter"),
a script to collect information from [IFTTT](http://www.ifttt.com "IFTTT") and
place it in a [Day One](http://dayoneapp.com, "Day One") journal. 

This fork of Sifttter Redux, rebranded as "Known Edition", changes the backend to upload the journal entries into [Known](http://www.withknown.com) site. It uses the Known API for it and creates a single post for every day (that is currently dated at 8pm). The post is not public so you have to be logged in at your site to see it.

# Todo

* use [Micropub](http://micropub.net/) for publishing to allow more versability in the backend
* add configuration option to change the visibility of the created Known entry (see [egoexpress/sifttter-redux-known#3](https://github.com/egoexpress/sifttter-redux-known/issues/3))
* set publishing date (see [egoexpress/sifttter-redux-known#3](https://github.com/egoexpress/sifttter-redux-known/issues/2))
* code cleanups

# Prerequisites

In addition to Git (which, given you being on this site, I'll assume you have),
Ruby (2.1 or greater) and some additional gems are needed. These are specified in the gemfile.

# Usage

Syntax and usage can be accessed by running `srd help`. Note that each command's options can be revealed by adding the `--help` switch after the command.

## IFTTT Template

Sifttter files from IFTTT need to follow this format:

```
@begin
@date April 21, 2014 at 12:34PM
**Any** sort of *Markdown* goes here...
@end
```

### Template Tokens

IFTTT templates can make use of the following tokens:

* `%time%`: the time the entry was created

As an example, to include the entry time in a template:

```
@begin
@date April 21, 2014 at 12:34PM
- %time%: My text goes here...
@end
```

## Initialization

```
$ srd init
```

Initialization will perform the following steps:

1. Download [Dropbox Uploader](https://github.com/andreafabrizi/Dropbox-Uploader "Dropbox-Uploder")
to a location of your choice if not already present.
2. Automatically configure Dropbox Uploader.
3. Collect some user paths and infos (note that you can use tab completion here!):
 * The location on your filesystem where files will be temporarily stored
 * The location of your files in Dropbox
 * The URL of your Known site
 * The username for the Known site
 * The API key for the Known site (find that one on https://<YOUR_KNOWN_SITE>/account/settings/tools/)

## Pathing

Note that when Sifttter Redux Known Edition asks you for paths, it will ask for "local" and
"remote" filepaths. It's important to understand the difference.

### Local Filepaths

Local filepaths are, as you'd expect, filepaths on your local machine. Some
examples might be:

* `/tmp/my_data`
* `/home/bob/ifttt/sifttter_data`
* `~/sifttter`

### Remote Filepaths

Remote filepaths, on the other hand, are absolute filepaths in your Dropbox
folder (*as Dropbox Uploader would see them*). For instance,
`/home/bob/Dropbox/Apps/Sifttter` is *not* a valid remote filepath; rather,
`/Apps/Sifttter` would be correct.

## Basic Execution

```
$ srd exec
# Creating entry: April 18, 2016
# Downloading Sifttter files...
# Done.
# Entry logged for April 18, 2016...
# Uploading entries to Known site https://known.example.org
# Uploading entry for 2016-04-18
# Upload done.
# Removing temporary local files...
```

## "Catch-up" Mode

Sometimes, events occur that prevent Sifttter Redux Known Edition from running (power loss to
  your device, a bad Cron job, etc.). In this case, "catch-up"
  mode can be used to collect any valid journal on or before today's date.

There are many ways to use this mode:

*  create an entry for yesterday: `srd exec -y`
* catch-up for a specific date: `srd exec -d 2014-02-14`
* last "N" days catch-up (e.g. last 3 days): `srd exec -n 3`
* last "N" days catch-up + today (e.g. last 3 days + today): `srd exec -i -n 3`
* last "N" week catch-up (e.g. last week): `srd exec -w 1`
* last "N" week catch-up + today (e.g. last week + today): `srd exec -i -w 1`
* create entries for a date range (e.g. from 2014-02-01 to 2014-02-12): `srd exec -f 2014-02-01 -t 2014-02-12`
* catch-up from a specific point in time until yesterday: `srd exec -f 2014-02-01`
* catch-up from a specific point in time until today: `srd exec -i -f 2014-02-01`

`-f` and `-t` are *inclusive* parameters, meaning that when specified, those
dates will be included when searching for Siftter data.
* Although you can specify `-f` by itself, you cannot specify `-t` by itself.

This tool makes use of the excellent
[Chronic gem](https://github.com/mojombo/chronic "Chronic"), which provides
natural language parsing for dates and times. This means that you can run
commands with more "human" dates like "last monday" or "yesterday".

See [Chronic's Examples section](https://github.com/mojombo/chronic#examples "Chronic Examples")
for more examples.

# Cron Job

By installing an entry to a `crontab`, Sifttter Redux Known Edition can be run automatically
on a schedule. The aim of this project was to use a Raspberry Pi; as such, the
instructions below are specifically catered to that platform. That said, it
should be possible to install and configure on any *NIX platform.

One issue that arises is the loading of the bundled gems; because cron runs in a
limited environment, it does not automatically know where to find installed gems.

## Using RVM

If your Raspberry Pi uses RVM, this `crontab` entry will do:

```
55 23 * * * /bin/bash -l -c 'source "$HOME/.rvm/scripts/rvm" && srd exec'
```

## Globally Installing Bundled Gems

Another option is to install the bundled gems to the global gemset:

```
$ bundle install --global
```

# Logging

Sifttter Redux logs a lot of good info to `~/.sifttter_redux_log`. It makes use
of Ruby's standard log levels:

* DEBUG
* INFO
* WARN
* ERROR
* FATAL
* UNKNOWN

If you want to see more or less in your log files, simply change the `log_level`
value in `~/.sifttter_redux` to your desired level.

# Bugs and Feature Requests

To report bugs with or suggest features/changes for Sifttter Redux Known Edition, please use
the [Issues Page](http://github.com/egoexpress/sifttter-redux-known/issues).

Contributions are welcome and encouraged. To contribute:

* [Fork Sifttter Redux Known Edition](http://github.com/egoexpress/sifttter-redux-known/fork).
* Create a branch for your contribution (`git checkout -b new-feature`).
* Commit your changes (`git commit -am 'Added this new feature'`).
* Push to the branch (`git push origin new-feature`).
* Create a new [Pull Request](http://github.com/egoexpress/sifttter-redux-known/compare/).

# License

(The MIT License)

Copyright © 2016 Bjoern Stierand <bjoern-github@innovention.de>
Sifttter Redux Copyright © 2014 Aaron Bach <bachya1208@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in the
Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Credits
* the [Indiewebcamp](https://indiewebcamp.com) crew who inspired me to fork Sifttter-Redux and create the Known backend during [IndieWebCamp Nuremberg 2016](https://indiewebcamp.com/2016/Nuremberg)
* Aaron Bach for creating [Siffter Redux](https://github.com/bachya/Sifttter-Redux)
* Craig Eley for [Sifttter](http://craigeley.com/post/72565974459/sifttter-an-ifttt-to-day-one-logger "Sifttter")
