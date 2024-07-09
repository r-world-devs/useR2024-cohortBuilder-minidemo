library(magrittr)
options("cb_active_filter" = FALSE)
# Load lobrarian dataset
load("librarian.rda")

# Check librarian dataset
str(librarian)
print(librarian)

# Create the source
librarian_source <- cohortBuilder::set_source(
  cohortBuilder::as.tblist(librarian)
)

## Alternativly
# Just create tblist from dataframes
# cohortBuilder::tblist(iris, cars)

# Create cohort
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
  cohortBuilder::run()

cohortBuilder::get_data(coh)

# cohortBuilder is R6 class
print(coh)

# You can manipulate cohortBuilder object
cohortBuilder::update_filter(
  coh, step_id = 1, filter_id = "copies",
  range = c(0, 10),
  run_flow = TRUE
)

cohortBuilder::get_data(coh)

# Use shinyCohortBuilder for gui
shinyCohortBuilder::gui(coh)


# Start using cohortBuilder with autofilter
librarian_source <- cohortBuilder::set_source(
  cohortBuilder::as.tblist(librarian),
  binding_keys = cohortBuilder::bind_keys(
    cohortBuilder::bind_key(
      update = cohortBuilder::data_key('books', 'isbn'),
      cohortBuilder::data_key('issues', 'isbn'),
      activate = TRUE
    ),
    cohortBuilder::bind_key(
      update = cohortBuilder::data_key('issues', 'isbn'),
      cohortBuilder::data_key('books', 'isbn'),
      activate = TRUE
    )
  )
) %>%
  shinyCohortBuilder::autofilter()

coh <- librarian_source %>%
  cohortBuilder::cohort()

shinyCohortBuilder::gui(coh)

