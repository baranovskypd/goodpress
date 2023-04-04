
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

**Limitation**: This package relies on the standard WordPress REST API but has only been tested on self-hosted Wordpress installations. It may or may not work with the centralised wordpress.com service (if it does, please report back, for instance in an issue).

**Important disclaimer**: I don’t use WordPress, so I am not sure you
should trust me. You are welcome to try out the package (not on
important stuff, rather in a playground of some sort), to contribute,
and to volunteer to take over this package/concept. If you write a newer
and better R package please tell me about it so I can add a link to it.

## Installation

You can install the released version of goodpress from its GitHub
repository:

``` r
# install.packages("remotes")
remotes::install_github("maelle/goodpress", ref = "main")
```

Then you will need to tweaks things **once** on your website for three
aspects

  - Authentication (this is **compulsory**)
  - Syntax highlighting (if you want to show R code in your posts)
  - Math (if you want to show math in your posts)

See `vignette("setup", package = "goodpress")`.

## Workflow

The summary is: create your posts in folders as index.Rmd with
`hugodown::md_document` output format; knit, `wp_post()`, rinse, repeat.

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
    path **to the post folder** as argument, create a draft post in your
    website, uploads all image media stored in the “figs” folder, edits
    the references to image media and then publishes the post.
  - The first time you run `wp_post()` for a folder, it creates a file
    called `.wordpress.yml` in the post folder, that contains, in
    particular, the URL and ID of the post on your WordPress website.
    This way, next time the function is run, the post is *updated*.

[Example post](https://rmd-wordpress.eu/post-rmd/) and [its
source](https://github.com/maelle/goodpress/tree/main/inst/post-example2).
Note that it includes citations as footnotes by using the [same strategy
as hugodown](https://github.com/r-lib/hugodown#citations).

**You could have one [big “blog” folder/RStudio
project](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/)
with each post as a sub-folder, [neatly
named](http://www2.stat.duke.edu/~rcs46/lectures_2015/01-markdown-git/slides/naming-slides/naming-slides.pdf)
YYYY-MM-DD-slug, and at the root of the blog folder you’d have this
script you’d run from the RStudio project**

``` r
wordpress_url <- # your url
today_post <- "2020-06-01-cool-post"
goodpress::wp_post(today_post, wordpress_url)
```

### Images and figures

  - For plots generated via R, just use R Markdown as you normally
    would.

  - For images not generated from R code, save them in the `figs`
    subfolder and use `knitr::include_graphics()` to include them. See
    [example post with a cat
    picture](https://rmd-wordpress.eu/post-slug/) and [its
    source](https://github.com/maelle/goodpress/tree/main/inst/post-example).

### Author

You can either

  - not write any author in the YAML metadata, and the author will be
    the authenticated user.
  - write an existing username which is useful when you are posting or
    editing on someone else’s behalf.

You cannot create an user with this package, you have to use WordPress
interface for that.

### Publication status

The default status of the post is “publish”. If you want another status
(status has to be one of: “publish”, “future”, “draft”, “pending”,
“private”) , write it in the yaml (and then knit index.Rmd again) e.g.

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

### Tags and categories

You can use tags and categories in the YAML metadata of index.Rmd
(rendered to index.md). If a tag or a category doesn’t exist `wp_post()`
will create it for you.

e.g.

``` yaml
---
title: "Title of the Post"
date: "2020-04-01T00:00:00"
slug: "post-slug"
excerpt: "Here I summarize this fantastic post"
status: "publish"
output: hugodown::md_document
categories:
  - math
  - code
tags:
  - crul
  - mathjax
  - R packages
---
```

Or (if there’s a single category or single tag)

``` yaml
---
title: "Another Rmd Blog Post"
date: "2020-04-01T00:00:00"
slug: "post-rmd"
excerpt: "Here I summarize this fantastic post"
output: hugodown::md_document
bibliography: refs.bib
suppress-bibliography: true
csl: chicago-fullnote-bibliography.csl
categories: R
tags:
  - citation
  - code
---
```

### Math with MathJax

First, add [MathJax JS script to your
website](https://maelle.github.io/goodpress/articles/setup.html#math-1),
**once**.

In every post where you want to use math, use [MathJax
input](https://docs.mathjax.org/en/latest/input/tex/index.html) (MathML,
LaTeX). After formulas put a few empty lines.

See [example post with math](https://rmd-wordpress.eu/post-slug/) and
[its
source](https://github.com/maelle/goodpress/tree/main/inst/post-example).

### Technical details

If you’re curious. 🙂

The “one post per folder” thing is inspired by [Hugo leaf
bundles](https://gohugo.io/content-management/page-bundles/).

At the moment this package uses the very handy
[`hugodown`](https://hugodown.r-lib.org/)’s R Markdown output format
which allows using `downlit` for R syntax highlighting without my having
to think too much.

On disk your post is stored as index.Rmd and index.md, but before upload
to the WordPress API it is transformed to HTML using
[Pandoc](https://pandoc.org/).

## Motivation

The current best tool for writing from R Markdown to WordPress,
[`knitr::knit2wp()`](https://tobiasdienlin.com/2019/03/08/how-to-publish-a-blog-post-on-wordpress-using-rmarkdown/),
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

  - You could set up something like a GitHub Action workflow that’d
    interact with WordPress REST API each time you push to the default
    branch.
  - Are you still sure you don’t want to use a [static website generator
    instead](https://gohugo.io/tools/migrations/)? 😉 More seriously, I
    am interested in blogging workflows so feel free to tell me why and
    how you use WordPress (in an issue for instance).
