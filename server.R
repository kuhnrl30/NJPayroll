library(shiny)
require(RJSONIO)
require(ggplot2)
require(scales)


  # This function is used to access the SODA API and download the data from the NJ Open
  # Data website.  The funtion takes the year as an input and downloads the first 1000
  # entries.
  GetData<- function(n){
    # Returns the dataframe from the download.  The dataframe is 1000 rows by 1 column.
    # The filters are applied by the string after the '?'.  The 'master' record type 
    # was used because it had the YTD earnings.  The alternative was to use the 
    # 'detail' record type which had current period payroll entries. 
    URL<-paste("http://data.nj.gov/resource/iqwc-r2w7.json?record_type=master&calendar_year=",n,sep="")
    RawData<-fromJSON(URL)
    
    Temp<- data.frame(salary= as.numeric(sapply(RawData,"[[","master_ytd_earnings")),
                      stringsAsFactors = F)
    L<-list(mu=mean(Temp$salary),
         SD=sd(Temp$salary),
         values=Temp$salary)
    L
  }

shinyServer(
  function(input,output){

    # Use reactive functions so the data gets re-queried whenever the year input
    # is changed by the user.
    Data<- reactive({GetData({input$year})})
    
    output$mu  <- renderText(Data()$mu)
    output$SD  <- renderText((Data()[2]))
    
    # Need to use reactive again to update these values when the data set
    # is queried.
    Norm<-reactive({
      xval<- seq(0,150000,length=10000)
      yval<- dnorm(xval,mean=as.numeric(Data()$mu), sd=as.numeric(Data()$SD))
      data.frame(x=xval,y=yval)
    })
    
    # Calculate the theoretical percentile the user's salary would
    # fall into.  Use theoretical percentile as a statistical 
    # inference of where they user would fall.
    Percentile<- reactive(pnorm(as.numeric({input$isalary}), 
                                mean=as.numeric(unlist(Data()[1])),
                                sd=as.numeric(Data()[2])
                                ))

    # Draw the plot.  The vertical line is the user's salary.
    output$plot1<- renderPlot({
      ggplot(Norm()) + 
      aes(x=x,y=y) +
        geom_line(size=1.5) +
        labs(title="Distribution of Salaries for New Jersey State Employees",
             y= element_blank())  +
        scale_x_continuous(labels=comma, limits=c(0,150000)) +
        geom_vline(xintercept={input$isalary}, colour="blue", size=2)  +
        theme(plot.title=element_text(size=rel(2)),
              axis.text.y=element_blank(),
              panel.background=element_rect(fill="white",colour="black"),
              panel.grid.major=element_blank(),
              panel.grid.minor= element_blank())
    })
    
    
    # Craft the sentence at the bottom of the chart.  The statement includes
    # a binary value indicating if the user's salary is greater than or less
    # than the mean.  It also gives the mean salary during the year.
    Bigger<-reactive({ifelse({input$isalary}< as.numeric(Data()[1]),"less","more")})
    output$statement<- renderText(paste("Your salary is ",
                                         Bigger()[1],
                                         " than the average NJ state worker salary in ",
                                         {input$year},
                                        ". The average pay that year was $",
                                        format(round(as.numeric(Data()[1]),0),big.mark = ","),
                                        " and you made more money than ",
                                        round(Percentile(),3)*100,
                                        "% of the state employees. Congrats!",
                                        sep=""))
  }
)
