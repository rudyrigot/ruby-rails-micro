## Meta-micro, Ruby on Rails example based on prismic.io

This is a example project made by the prismic.io team as a showcase to help developers get started. By default, it consumes the content repository available at [https://micro.prismic.io/api](https://micro.prismic.io/api).

### Get started

This project gets started and installed exactly like the Rails starter project, you will find all information [in its README file](https://github.com/prismicio/ruby-rails-starter).

#### Connect it to your own Meta-micro repository

First, create your own WorldChanger content repository if you haven't: from your [prismic.io dashboard](https://prismic.io/dashboard/), click on the "Fork it now!" button in the "Fork the Meta-micro repository" frame.

Then, configure the project as described in the "Configure" paragraph of [the starter project's README file](https://github.com/prismicio/ruby-rails-starter).

Now, you can change content in your Meta-micro repository, and it will reflect in your local project.

To get the OAuth configuration working, go to the Applications panel in your repository settings, and create an OAuth application to allow interactive sign-in. Just create a new application, fill the application name and the callback URL (localhost URLs are always authorized, so at development time you can omit to fill the Callback URL field), and copy/paste the clientId & clientSecret tokens into the `config/prismic.yml` file.

### Starter Kit Documentation

You should check out [the "Kits and helpers" section of our API documentation](https://developers.prismic.io/documentation/UjBe8bGIJ3EKtgBZ/api-documentation#kits-and-helpers), which sets general information about how our kits work, and [the "Kit documentation" of the Ruby development kit](https://github.com/prismicio/ruby-kit) for specifics about how the gem works.

Below are some extra helpers included in this starter kit to make your life easier.
 * There's no need for a `ctx` object to pass around: the API object can be retrieved through the `api` method of the controller (which initializes it if it wasn't), and `ref` is an instance variable that is set before every call to the controller.
 * A `PrismicService` class is included, which comes with a few interesting methods, including `PrismicService.get_document(id,api,ref)` to make a quicker query from an ID. For instance, you can call a bookmarked document really easily: `PrismicService.get_document(api.bookmark('home'),api,ref)`
 * A `PrismicHelper` module is also provided, that provides several interesting methods to use in views, including a basic `link_resolver` method to be used out of the box (read more about this method in our "Kits and helpers" documentation).

### Licence

This software is licensed under the Apache 2 license, quoted below.

Copyright 2013 Zengularity (http://www.zengularity.com).

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this project except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
