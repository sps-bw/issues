# Black and White Issue Packager

This Ruby Rake setup allows you to put some images and markdown files into folders and generate a `.hpub` file ready to upload to the Amazon S3 bucket.

### Setup

Install Ruby on your system if you don't have it already (I recommend RVM). Then `bundle install` to install all the dependencies.

## 1. Create a new issue

Run `rake new ISSUE=n`, where `n` is the next issue number, to create all the folders you need
