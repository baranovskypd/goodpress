test_that("wp_post works", {
  # create file under tests for that (with a .wordpress.yml file!)
  vcr::use_cassette("example2", {

    post_folder <- system.file(file.path("post-example2"), package = "goodpress")
    tmp_post_folder <- file.path(tempdir(), "post")
    dir.create(tmp_post_folder)
    file.copy(dir(post_folder, full.names = TRUE), tmp_post_folder)
    file.copy(test_path("wordpress.yml"), file.path(tmp_post_folder, ".wordpress.yml"))
    wordpress_url <- "https://rmd-wordpress.eu"

    x <- wp_post(tmp_post_folder,
                 wordpress_url = "https://rmd-wordpress.eu")

    expect_is(x, "character")

    file.remove(dir(tmp_post_folder, full.names = TRUE))

  })
})
