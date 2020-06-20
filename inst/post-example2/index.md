---
title: "Another Rmd Blog Post"
date: "2020-04-01T00:00:00"
slug: "post-rmd"
excerpt: "Here I summarize this fantastic post"
output: hugodown::md_document
bibliography: refs.bib
suppress-bibliography: true
csl: chicago-fullnote-bibliography.csl
rmd_hash: 5c196b65a646789f

---

R Markdown
----------

A citation[^1]. R is cool[^2].

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <a href="http://rmarkdown.rstudio.com" class="uri">http://rmarkdown.rstudio.com</a>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/summary.html'>summary</a></span>(<span class='k'>cars</span>)
<span class='c'>#&gt;      speed           dist       </span>
<span class='c'>#&gt;  Min.   : 4.0   Min.   :  2.00  </span>
<span class='c'>#&gt;  1st Qu.:12.0   1st Qu.: 26.00  </span>
<span class='c'>#&gt;  Median :15.0   Median : 36.00  </span>
<span class='c'>#&gt;  Mean   :15.4   Mean   : 42.98  </span>
<span class='c'>#&gt;  3rd Qu.:19.0   3rd Qu.: 56.00  </span>
<span class='c'>#&gt;  Max.   :25.0   Max.   :120.00</span></code></pre>

</div>

Including Plots
---------------

You can also embed plots, for example:

<div class="highlight">

<img src="figs/pressure-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.

Another plot
------------

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/graphics/plot.html'>plot</a></span>(<span class='m'>1</span><span class='o'>:</span><span class='m'>10</span>, col = <span class='m'>3</span>)
</code></pre>
<img src="figs/unnamed-chunk-1-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Some other thing
----------------

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/MathFun.html'>sqrt</a></span>(<span class='m'>4</span>)
<span class='c'>#&gt; [1] 2</span></code></pre>

</div>

[^1]: Rich FitzJohn et al., *Jqr: Client for 'Jq', a 'Json' Processor*, 2018, <https://CRAN.R-project.org/package=jqr>.

[^2]: R Core Team, *R: A Language and Environment for Statistical Computing* (Vienna, Austria: R Foundation for Statistical Computing, 2020), <https://www.R-project.org/>.

