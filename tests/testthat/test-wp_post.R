test_that("wp_post works", {
  vcr::use_cassette("example2", {

    # Copy content of example post folder to a temporary folder
    post_folder <- system.file(file.path("post-example2"), package = "goodpress")
    tmp_post_folder <- file.path(tempdir(), "post")
    dir.create(tmp_post_folder)
    file.copy(dir(post_folder, full.names = TRUE), tmp_post_folder)

    # add the hidden wordpress YAML file
    file.copy(test_path("wordpress.yml"), file.path(tmp_post_folder, ".wordpress.yml"))

    # Just test that... we don't get errors :-s
    x <- wp_post(tmp_post_folder,
                 wordpress_url = "https://rmd-wordpress.eu")

    expect_is(x, "character")

    # Delete the temporary folder
    file.remove(dir(tmp_post_folder, full.names = TRUE))

  })
})
