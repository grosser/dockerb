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

`docker` -> `dockerb` ... everything else works like before

Dockerfile will be generated, you should delete it and not commit it.

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/dockerb.png)](https://travis-ci.org/grosser/dockerb)
