#app.R

library(shiny)
library(ggplot2)
library(plotly)
library(tidyverse)
library(shiny.semantic)
library(shiny.i18n)
library(leaflet)
library(polivax)
library(plotly)

setwd("C:/Dropbox/R/polivax")

i18n <- Translator$new(translation_json_path = "data/translation.json")
i18n$set_translation_language("de") # here you select the default translation to display

css <- "
.div{
  padding: 0px 0px 0px 0px;
}
.icon{
  padding: 0px 0px 0px 0px;
}
.leaflet-container {
  background: white;
}
"


# Define UI for application that draws a histogram
ui <- semanticPage(margin = "0px",
    title = "Polivax",
    tags$head(tags$style(HTML(css))),
    shiny.i18n::usei18n(i18n),
    div(class = "container-fluid", style = "font-size: 30px; padding: 20px 20px 30px 20px; background-color: #008084; color:white; line-height: 1;", "Polivax",
        div(style = "float:right; padding: 0px 0px 0px 0px;",
            dropdown_menu(icon("large hamburger"), 
                      menu(menu_header(icon("file"), i18n$t("About"),is_item = FALSE), 
                           menu_item(icon("wrench"), i18n$t("Methods"), href = "#methods"), 
                           menu_item(icon("download"), i18n$t("Get graphs")), 
                           menu_divider(), 
                           menu_header(icon("user"), i18n$t("Credits"), is_item = FALSE), 
                           menu_item(icon("wordpress"), i18n$t("Author"), href = "http://sciflow.eu"), 
                           menu_item(icon("github"), i18n$t("Fork me"), href = "https://github.com/upfl0/polivax"),
                           menu_divider(), 
                           menu_header(icon("comment"), i18n$t("Change language"), is_item = FALSE),
                           selectInput('selected_language',
                                       "",
                                       choices = i18n$get_languages(),
                                       selected = i18n$get_key_translation())
                      ), 
                      class = "", name = "main_dropdown", is_menu_item = TRUE))
    ),
    leafletOutput("vacc_map"),
    div(class = "ui container", style = "padding: 20px 20px 20px 20px; background: white; max-width = 1000px;",
    
        
        box_ui(div(
                h1(class = "ui header", style = "text-align:center;", i18n$t("Total number of COVID-19 vaccination doses administered")),
                div(plotlyOutput("plot_vaccinated", width = "100%", height = "100%"))
                #div(style = "text-align:center;", i18n$t("Total number of COVID-19 vaccination doses administered"))
               )),
        box_ui(div(
            h1(class = "ui header", style = "text-align:center;", i18n$t("Number of COVID-19 vaccination doses administered per 100 inhabitants")),
            div(plotlyOutput("plot_vaccinated_relative", width = "100%", height = "100%"))
            #div(style = "text-align:center;", i18n$t("Total number of COVID-19 vaccination doses administered"))
            )),
        
        
        
        htmlOutput("methods_tag"),
        
        h1(class = "ui header", style = "text-align:center;", i18n$t("Methods")),
        
        box_ui(includeMarkdown("data/methods.Rmd"))
    )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    observeEvent(input$selected_language, {
        # This print is just for demonstration
        print(paste("Language change!", input$selected_language))
        # Here is where we update language in session
        shiny.i18n::update_lang(session, input$selected_language)
        output$vacc_map <- render_vacc_map(sel_lang = input$selected_language)
        output$plot_vaccinated <- render_bar_plot(sel_lang = input$selected_language, relative = FALSE)
        output$plot_vaccinated_relative <- render_bar_plot(sel_lang = input$selected_language, relative = TRUE)
    })
    
    output$methods_tag <- renderText({
        "<div id='methods'>&nbsp;</div>"
    })
    
    #output$methods <- markdown("data/methods.rmd")
    
    output$distPlot <- renderPlot({
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        hist(x, breaks = bins,
             col = "darkgray", border = "white",
             main = i18n$t("Histogram of x"), ylab = i18n$t("Frequency"))
    })
    
    
    
 
}


# Run the application 
shinyApp(ui = ui, server = server)