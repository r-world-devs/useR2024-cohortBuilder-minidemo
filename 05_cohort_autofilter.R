# shinyCohortBuilder autofilter
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
      activate = TRUE,
    )
  )
) %>%
  shinyCohortBuilder::autofilter()

coh <- librarian_source %>%
  cohortBuilder::cohort()

shinyCohortBuilder::gui(coh)
