
<!-- README.md is generated from README.Rmd. Please edit that file -->

# goodpress (or badpress?)

> Write to WordPress, from R Markdown, with a modern stack.

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R build
status](https://github.com/maelle/goodpress/workflows/R-CMD-check/badge.svg)](https://github.com/maelle/goodpress/actions?query=workflow%3AR-CMD-check)
[![Codecov test
coverage](https://codecov.io/gh/maelle/goodpress/branch/main/graph/badge.svg)](https://codecov.io/gh/maelle/goodpress?branch=main)
<!-- badges: end -->

The goal of goodpress is to post to [WordPress](https://wordpress.org/)
from [R Markdown](https://rmarkdown.rstudio.com/). I need this prototype
for [a course](https://scientific-rmd-blogging.netlify.app/). 😺

**Important disclaimer**: I don’t use WordPress, so I am not sure you
should trust me. You are welcome to try out the package (not on
important stuff, rather in a playground of some sort), to contribute,
and to volunteer to take over this package/concept. If you write a newer
and better R package please tell me about it so I can add a link to it.

## Installation

You can install the released version of goodpress from this repository:

``` r
# install.packages("remotes")
remotes::install_github("maelle/goodpress", ref = "main")
```

Then you will need to tweaks things on your website for three aspects

  - Authentication (this is *compulsory*)
  - Syntax highlighting
  - Math

You only need to do these *once*, so that’s only potentially painful at
setup.

You might not need to tweak syntax highlighting and math stuff if you,
well, never show code or never show math equations in your posts.

### Authentication

From WordPress point-of-view this package is a “remote application”
therefore it needs your website to use an [authentication
*plugin*](https://developer.wordpress.org/rest-api/using-the-rest-api/authentication/#authentication-plugins).
At the moment, for the sake of simplicity, this package only relies on
[Application
Passwords](https://wordpress.org/plugins/application-passwords/).

You cannot install plugins if you use wordpress.com (unless you have a
costly business plan there), therefore with wordpress.com you cannot use
the REST API. There are paid services out there providing a domain name,
hosting and a one-click WordPress install, for a few dollars a month,
that you could use if you don’t roll your own server.

Here’s what I did to be able to use this package on my [test
website](https://rmd-wordpress.eu/):

  - Installed and activated the [Application Passwords
    plugin](https://wordpress.org/plugins/application-passwords/).
    *Don’t forget to keep your WordPress plugins up-to-date especially
    because of security updates.*
  - Created a new user with editor rights, not admin, and from the admin
    panel I created an application password for “rmarkdown” for that
    user. *Doing this for an user with restricted access is safer.*
  - In `.Renviron`, save username as `WP_USER` and password as `WP_PWD`.
    *Keep `.Renviron` safe, it contains secrets\!*
  - Edited the [.htaccess file of my
    website](https://github.com/georgestephanis/application-passwords/wiki/Basic-Authorization-Header----Missing).

### Syntax highlighting

#### For R

To get syntax highlighting for R blocks, at the moment you need to add
custom CSS (once, like the plugin setup stuff).

  - Find `system.file(file.path("css", "code.css"), package =
    "goodpress")` and copy it to your clipboard.
  - From your WordPress admin dasbhoard, go to Appearance \> Customize
    \> Additional CSS. Paste the CSS there and click on publish.

You could edit colors that are in the CSS file.

Later I hope to make this process easier, maybe by adding inline styles.

#### Other languages

I haven’t explored that yet.

### Math

  - Use [MathJax
    input](https://docs.mathjax.org/en/latest/input/tex/index.html) (can
    also be MathML)
  - Customize your theme. From WordPress interface go to Appearance \>
    Theme Editor. Add the lines below (that come from [MathJax
    docs](https://www.mathjax.org/#gettingstarted)) to the `<head>` div
    of `header.php`, then save.

<!-- end list -->

``` html
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
```

See [example post with math](https://rmd-wordpress.eu/post-slug/) and
[its
source](https://github.com/maelle/goodpress/tree/main/inst/post-example).

## Workflow

  - Create your posts in folders, one folder per post, with index.Rmd
    knitted to index.md and figures under a “figs” folder.

<!-- end list -->

``` r
fs::dir_tree(system.file(file.path("post-example2"), package = "goodpress"))
#> /home/maelle/R/x86_64-pc-linux-gnu-library/3.6/goodpress/post-example2
#> ├── chicago-fullnote-bibliography.csl
#> ├── figs
#> │   ├── pressure-1.png
#> │   └── unnamed-chunk-1-1.png
#> ├── index.Rmd
#> ├── index.md
#> └── refs.bib
```

  - The post index.Rmd should use
    [`hugodown::md_document`](https://hugodown.r-lib.org/reference/md_document.html)
    as an output format.
  - Knit your post and then, run the function `wp_post()` that takes the
    path as argument, create a draft post in your website, uploads all
    image media stored in the “figs” folder, edits the references to
    image media and then publishes the post.
  - The first time you run `wp_post()` in a folder, it creates a file
    called `.wordpress.yml` that contains, in particular, the URL and ID
    of the post on your WordPress website. This way, next time the
    function is run, the post is *updated*.

[Example post](https://rmd-wordpress.eu/post-rmd/) and [its
source](https://github.com/maelle/goodpress/tree/main/inst/post-example2).
Note that it includes citations as footnotes by using the [same strategy
as hugodown](https://github.com/r-lib/hugodown#citations).

  - The default status of the post is “publish”. If you want another
    status (status has to be one of: “publish”, “future”, “draft”,
    “pending”, “private”) , write it in the yaml (and then knit
    index.Rmd again) e.g.

<!-- end list -->

``` yaml
---
title: "Title of the Post"
date: "2020-04-01T00:00:00"
slug: "post-slug"
excerpt: "Here I summarize this fantastic post"
status: "private"
output: hugodown::md_document
---
```

The package cannot handle private posts with password, only private
posts that are visible to admins and editors only. You could create a
private post, and then from the WordPress interface make it visible with
password. Make it private again before trying to update the post with
the R package.

The “one post per folder” thing is inspired by Hugo leaf bundles.

On disk your post is stored as index.Rmd and index.md, but before upload
to the WordPress API it is transformed to HTML using
[Pandoc](https://pandoc.org/).

## Motivation

The current best tool for writing from R Markdown to WordPress,
[`knitr::knit2wp()`](http://tobiasdienlin.com/2019/03/08/how-to-publish-a-blog-post-on-wordpress-using-rmarkdown/),
relies on a package that hasn’t been updated in years and that depends
on the no longer recommended
[`RCurl`](https://frie.codes/curl-vs-rcurl/) and `XML`. In the meantime,
WordPress gained a [REST API](https://developer.wordpress.org/rest-api/)
that to my knowledge isn’t wrapped in any [working R
package](https://github.com/jaredlander/wordpressr).

There is also the solution to [use a plug-in to sync a GitHub repo with
a WordPress blog](https://github.com/mAAdhaTTah/wordpress-github-sync/)
(see [this website](https://abcdr.thinkr.fr/soumettre-un-article/) and
[its source](https://github.com/ThinkR-open/abcdR)) but it doesn’t
handle media. If you use a GitHub repo:

  - You could set up something like a GitHub Action that’d interact with
    WordPress REST API each time you push to the default branch.
  - Are you still sure you don’t want to use a [static website generator
    instead](https://gohugo.io/tools/migrations/)? :wink: More
    seriously, I am interested in blogging workflows so feel free to
    tell me why you use WordPress (in an issue for instance).
