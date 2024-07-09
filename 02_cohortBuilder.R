library(magrittr)

librarian_source <- cohortBuilder::set_source(
  cohortBuilder::as.tblist(librarian)
)

## Alternativly
# Just create tblist from dataframes
# cohortBuilder::tblist(iris, cars)
coh <- librarian_source %>%
  cohortBuilder::cohort(
    cohortBuilder::step(
      cohortBuilder::filter(
        "discrete", id = "author", dataset = "books",
        variable = "author", value = "Dan Brown", active = TRUE
      ),
      cohortBuilder::filter(
        "range", id = "copies", dataset = "books",
        variable = "copies", range = c(5, 10), active = TRUE
      ),
      cohortBuilder::filter(
        "date_range", id = "registered", dataset = "borrowers",
        variable = "registered", range = c(as.Date("2010-01-01"), Inf),
        active = TRUE
      )
    )
  ) |>
  cohortBuilder::run

cohortBuilder::get_data(coh)

# Update filters
cohortBuilder::update_filter(
  coh, step_id = 1, filter_id = "copies",
  range = c(0, 10)
)

# Run cohort
cohortBuilder::run(coh)
cohortBuilder::get_data(coh)

# You can also interact with cohort as it's R6 class
cohortBuilder::update_filter(
  coh, step_id = 1, filter_id = "copies",
  range = c(5, 10)
)
coh$run_flow()
cohortBuilder::get_data(coh)

