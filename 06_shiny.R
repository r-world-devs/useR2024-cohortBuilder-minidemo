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

  # Application title
  titlePanel("shinyCohortBuilder Demo"),

  # Sidebar
  sidebarLayout(
    sidebarPanel(
      shinyCohortBuilder::cb_ui("librarian")
    ),

    # Show a librarian
    mainPanel(
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

}

# Run the application
shinyApp(ui = ui, server = server)
