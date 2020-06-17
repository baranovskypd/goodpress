
<!-- README.md is generated from README.Rmd. Please edit that file -->

# goodpress (or badpress?)

> Write to Wordpress, from R Markdown, with a modern stack.

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
<!-- badges: end -->

The goal of goodpress is to post to Wordpress from R Markdown. This is
mostly a prototype since I don’t use Wordpress myself. I need the
prototype for a course. :smile\_cat:

**Important disclaimer**: I don’t use Wordpress, so I am not sure you
should trust me. You are welcome to volunteer to take over this
package/concept, but please tell me about it so I can add a link to your
package.

## Installation

You can install the released version of goodpress from this repository:

``` r
# install.packages("remotes")
remotes::install_github("maelle/goodpress", ref = "main")
```

### Authentication

From Wordpress point-of-view this package is a “remote application”
therefore it needs your website to use an [authentication
*plugin*](https://developer.wordpress.org/rest-api/using-the-rest-api/authentication/#authentication-plugins).
At the moment, for the sake of simplicity, this package only relies on
[Application
Passwords](https://wordpress.org/plugins/application-passwords/).

You cannot install plugins if you use wordpress.com (unless you have a
costly business plan there), therefore with wordpress.com you cannot use
the REST API. There are paid services out there providing a domain name,
hosting and a one-click Wordpress install, for a few dollars a month,
that you could use if you don’t roll your own server.

Here’s what I did to be able to use this package on my [test
website](https://rmd-wordpress.eu/):

  - Installed and activated the [Application Passwords
    plugin](https://wordpress.org/plugins/application-passwords/).
  - Created a new user with editor rights, not admin, and from the admin
    panel I created an application password for “rmarkdown” for that
    user.
  - In `.Renviron`, save username as `WP_USER` and password as `WP_PWD`.
  - Edited the [.htaccess file of my
    website](https://github.com/georgestephanis/application-passwords/wiki/Basic-Authorization-Header----Missing)

## Workflow

Partly aspirational for now.

  - Create your posts in folders, one folder per post, with index.Rmd
    knitted to index.md and figures under figures.
  - The post should use the template provided in this package. It is
    rendered to Markdown. *TODO: Make this an actual usable template, or
    maybe even an output format à la hugodown.*
  - Run the function `wp_post()` that takes the path as argument and
    (*TODO*) uploads media.

## Motivation

The current best tool for writing from R Markdown to Wordpress,
[`knitr::knit2wp()`](http://tobiasdienlin.com/2019/03/08/how-to-publish-a-blog-post-on-wordpress-using-rmarkdown/),
relies on a package that hasn’t been updated in years and that depends
on the no longer recommended
[`RCurl`](https://frie.codes/curl-vs-rcurl/) and `XML`. In the meantime,
Wordpress gained a [REST API](https://developer.wordpress.org/rest-api/)
that to my knowledge isn’t wrapped in any [working R
package](https://github.com/jaredlander/wordpressr).

There is also the solution to [use a plug-in to sync a GitHub repo with
a Wordpress blog](https://github.com/mAAdhaTTah/wordpress-github-sync/)
(see [this website](https://abcdr.thinkr.fr/soumettre-un-article/) and
[its source](https://github.com/ThinkR-open/abcdR)) but it doesn’t
handle media. If you use a GitHub repo:

  - You could set up something like a GitHub Action that’d interact with
    Wordpress REST API each time you push to the default branch.
  - Are you still sure you don’t want to use a [static website generator
    instead](https://gohugo.io/tools/migrations/)? :wink: More
    seriously, I am interested in blogging workflows so feel free to
    tell me why you use Wordpress (in an issue for instance).
