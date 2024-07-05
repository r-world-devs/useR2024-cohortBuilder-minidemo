# shinyCohortBuilder
library(magrittr)

# Load lobrarian dataset
# load("librarian.rda")

# Create binding keys
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
)

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
        variable = "copies", range = c(0, 10), active = TRUE
      ),
      cohortBuilder::filter(
        "date_range", id = "registered", dataset = "borrowers",
        variable = "registered", range = c(as.Date("2010-01-01"), Inf),
        active = TRUE
      )
    ),
    run_flow = TRUE
  )

# Run simple cohort gui
shinyCohortBuilder::gui(coh)
shinyCohortBuilder::gui(coh, steps = FALSE, stats = "pre", run_button = "global")

