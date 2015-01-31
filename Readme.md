Dockerfile.erb - use ruby in your dynamic Dockerfile

Install
=======

```Bash
gem install dockerb
```

or standalone
```Bash
curl https://rubinjam.herokuapp.com/pack/dockerb > dockerb && chmod +x dockerb
```

Usage
=====

`docker` generates a `Dockerfile` from your `Dockerfile.erb`
(delete it after building / do not commit it)

### custom

```
RUN echo <%= "hello" + " " + "world" %>
---
RUN echo hello world
```

### install_gem

Pre-install a slow gem so re-building the container is fast
 - picks the correct version from Gemfile.lock
 - use before Adding Gemfile.lock or bundling

```
<%= install_gem 'nokogiri' %>
---
RUN gem install -v 1.6.3 nokogiri
```


### bundle

 - add as little as necessary to bundle
 - do not fail when re-locking fails due to git not being installed (`|| bundle check`)

```
<%= bundle %>
---
ADD Gemfile /app/
ADD Gemfile.lock /app/
ADD vendor/cache /app/vendor/cache
RUN bundle install --quiet --local --jobs 4 || bundle check
```

Inside of ruby:

```Ruby
Dockerb.compile do
  ... do other things ...
end
# Dockerfile is cleaned up
```

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/dockerb.png)](https://travis-ci.org/grosser/dockerb)
