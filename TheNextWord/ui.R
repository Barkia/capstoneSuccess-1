library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(theme="bootstrap.min.css",
  
    # Application title.
    tags$div(class="jumbotron text-center",
             tags$blockquote(h3("My Awesome Word Predictor"),
                tags$footer(style="font-size:larger","By Vivek Tiwari"))),
    
    #Side-bar accepts form-input and some self-info
    sidebarLayout(
        sidebarPanel(
            textInput("obs", "Enter Your Statement Here:"),
            
            helpText("We will try to predict the next most likely word based on user-input above.(simply type and press enter or click button)"),
            
            submitButton("Predict Next Word"),
            tags$hr(),
            tags$blockquote("The design of UI is material-design made with help of bootstrap paper theme variation.",tags$hr(),"Thanks to everyone who helped on forum to clear doubts regarding stemming problems during initial experimentation.",tags$footer(tags$cite("me citation test")),tags$hr(),"Github repo for this accesbile at :: ",tags$a("https://github.com/vivekdtiwari/capstoneSuccess"))
        ),
      mainPanel(
          h6("You input the following text:"),
          textOutput("Original"),
          br(),
          h6("Your statement has been reformated to the following:"),
          textOutput("Translated"),
          br(),
          br(),
          h3("Most Likely Next Word:"),
          div(textOutput("BestGuess"), style = "color:red"),
          br(),
          h3("The program guessed your word based on the following data:"),
          tableOutput("view")
    )
  )
))
