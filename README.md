# RubyKaizen

Take a look at [www.rubykaizen.com](http://www.rubykaizen.com).

This is an entry for [Rails Rumble 2013](http://railsrumble.com/), a 48-hour web development competition. Our team:

- Belén Albeza [@ladybenko](https://twitter.com/ladybenko)
- Ernesto Jiménez [@ernesto_jimenez](https://twitter.com/ernesto_jimenez)
- Blanca Tortajada [@blanca_tp](https://twitter.com/blanca_tp)

## For developers

### Requirements

- OpenSSL
- MongoDB
- Redis
- Ruby 2.0
- Bundler

### Run app locally

Checkout and install dependencies:

```
git clone git@github.com:railsrumble/r13-team-72.git
bundle install
```

The `server` task starts WEBrick and auto-reloads code:

```bash
rake server
QUEUE='*' rake resque:work
```

To start processing a repo you can do the following:

```bash
mkdir repos
rake queue_repo\[https://github.com/flori/json\]
```

### Tests

Run tests with RSpec.

```bash
rspec spec/sample_spec.rb
```

### Sass + Compass

Add Compass / Sass stylesheets to `public/stylesheets/sass`. They will be compiled and available in `public/stylesheets`. You can add the stylesheets in your HTML like this:

```html
<!-- for main.sass -->
<link rel="stylesheet" href="/stylesheets/main.css">
```
