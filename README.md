
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
mostly a prototype since I don’t use Wordpress myself: therefore
goodpress is up for adoption\!

**Important disclaimer**: I don’t use Wordpress, so I am not sure you
should trust me.

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
Application Passwords.

You cannot install plugins if you use wordpress.com (unless you have a
costly business plan there), therefore with wordpress.com you cannot use
the REST API. There are services out there providing a domain name,
hosting and a one-click Wordpress install, that you could use if you
don’t roll your own server. ADD STEPS I FOLLOWED.

## Example

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
```

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

  - You could set up a GitHub action that’d interact with Wordpress REST
    API each time you push to the default branch.
  - Are you still sure you don’t want to use a [static website generator
    instead](https://gohugo.io/tools/migrations/)? :wink: More
    seriously, I am interested in blogging workflows so feel free to
    tell me why you use Wordpress (in an issue for instance).
