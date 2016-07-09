library(shiny)

shinyUI(fluidPage(theme="journal.css",
  #pageWithSidebar
  
  #Application Title
  headerPanel("NJ State Employee Salaries"),
  
  # Sidebar with controls to select which year of data to pull and 
  # to enter the users salary. The helpText function is used to 
  # disclaim the number of datapoints used in the chart and to 
  # imply the methodology. Sepcifically, to call out that only 
  # the first 1,000 data points are used which is not a statistical
  # sample of salaries. The submitButton defers the rendering of output 
  # until the user explicitly clicks the button (rather than doing it 
  # immediately when inputs change). This is useful because the function 
  # submits an API call and then must format the data before it is 
  # presented.
  
  sidebarPanel(h3("Enter your salary and see how you stack up against the New Jersey state employees!"),
               numericInput("isalary",'Your Salary(USD)',0,min=0,max=150000,step=1),
               selectInput("year","Choose the year",choices=c("2010","2011","2012", "2013","2014")),
               helpText("Note: This function may take a few moments to load ",
                        "if you change the year because it must download the",
                        "new data from the NJ Open Data website for each update."),
               submitButton("Update View")),
  
  # The main panel presents the s chart with a gaussian
  # curve with the same characteristics as the actual
  # data.  The main panel also shows the user's salary
  # and the quantile where the user falls in the 
  # distribution.
  mainPanel(
    tabsetPanel(
      tabPanel("Chart",
               plotOutput("plot1"),
               textOutput("statement")),
      tabPanel("Documentation",
               p("Dear Reader,"),
               p("The purpose of this application is to allow the user to compare",
                 "their salary to the average salary of the New Jersey state employees.",
                 "The user inputs a numerical value from 0 through 150,0000.  Next,",
                 "the user will select the year they wish to compare their salary to.",
                 "The application takes these two inputs and creates a chart with",
                 " a normal distribution and a vertical line with the users input. ",
                 "The normal distribution has the same mean and standard deviation",
                 "as the employee salary data for the relevant year"),
               p("The salary data is obtained from the New Jersey Open Data website ",
                 "using the Socrata Open Data API (SODA) ",
                 "from https://data.nj.gov/resource/iqwc-r2w7.json. The data",
                 "is refreshed everytime the user loads the app or changes the year",
                 "input value.  The API only allows 1,000 queries through the API",
                 " without using a application key and token.  Since the code for",
                 " this app will be shared on Github, no key was used. Since the ",
                 "is not logically sorted when downloaded, it was naively assumed that",
                 "the compensation data was randomly distributed.  Therefore, it is",
                 "possible to statistical inference to predict the percentile and ",
                 "determine the error margins."),
               p("Thank you for using this app. If you enjoyed using this app, please",
                 "head to", tags$b(tags$a(href="http://kuhnrl30.github.io",target="_blank","http://kuhnrl30.github.io")),
                 " to see more of my work."),
               p("Thank you,"),
               p("Ryan"))))
))
