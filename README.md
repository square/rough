# Rough

Rough is RPC for Rails.

## Usage

Using `Rough` is very simple.  All you need to do is add `rpc` to
`config/routes.rb` like so:

``` ruby
get '/something' => 'something#index', rpc: 'Something::SomethingService#list'
```

and have `ApplicationController` (or a subset of your controllers) include
`Rough::BaseController`.

In your controllers, you'll then have access to the request and response protos,
and they'll automatically be serialized/de-serialized to JSON or RPC, keeping
things nice and consistent:

``` ruby
class Something
  def index
    response_proto.name = [request_proto.first_name, request_proto.last_name].join(' ')
  end
end
```

## What happens

By doing that, your routes will be accessible over RPC, and also via traditional
HTTP (as defined in the normal routes syntax).

HTTP:

```
GET /something?param=one
RESPONSE JSON: { "some": "output" }
```

RPC via connector:

```
POST /services/something.SomethingService/List
REQUEST PROTO: SomethingRequest.new(param: 'one')
RESPONSE PROTO: SomethingResponse.new(some: 'output')
```

## Warming Cache

Some applications may choose to warm the route cache on startup.  To do so:

``` ruby
Rough::RouteRegistry.warm!
```

## Running Specs

`rake`

## Releasing

`rake release`

This will run the tests, build the gem, tag and release the current code,
at the version specified in `Rough::VERSION`.

License
=======

    Copyright 2015 Square, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
