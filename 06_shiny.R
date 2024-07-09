#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(magrittr)
options("cb_render_all" = TRUE)
options("cb_active_filter" = FALSE)

ui <- fluidPage(
  shiny::tags$style("code.hl.background {color: #000 !important};"),
  # Application title
  titlePanel("shinyCohortBuilder Demo"),

  # Sidebar
  sidebarLayout(
    sidebarPanel(
      shinyCohortBuilder::cb_ui("librarian")
    ),

    # Show a librarian
    mainPanel(
      actionButton("update_filter", "Update filter"),
      verbatimTextOutput("cohort_data")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  # Create binding keys
  librarian_source <- librarian[c("books", "issues")] %>%
    cohortBuilder::as.tblist() %>%
    cohortBuilder::set_source(
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
    shinyCohortBuilder::autofilter(gui_args = list(search = FALSE))

  coh <- librarian_source %>%
    cohortBuilder::cohort()

  shinyCohortBuilder::cb_server("librarian", coh, feedback = TRUE)

  returned_data <- shiny::eventReactive(input[["librarian-cb_data_updated"]], {
    coh$get_data(step_id = coh$last_step_id(), state = "post")
  }, ignoreInit = FALSE, ignoreNULL = FALSE)

  output$cohort_data <- renderPrint({
    returned_data()
  })

  observeEvent(input$update_filter, {
    id <- coh$get_filter("1") %>% purrr::keep(~ .x$name == "copies") %>% names()
    cohortBuilder::update_filter(
      coh, step_id = 1, filter_id = id,
      label = "Copies",
      range = c(1, 2), active = TRUE
    )

    cohortBuilder::run(coh)
    ns <- coh$attributes$session$ns
    shiny::removeUI(glue::glue("#{ns(1)}"), session = coh$attributes$session, immediate = TRUE)
    shinyCohortBuilder:::render_steps(coh, coh$attributes$session, init = FALSE)
  })

}

# Run the application
shinyApp(ui = ui, server = server)
