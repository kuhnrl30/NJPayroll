# Load the data from NJ Payroll
require(RJSONIO)
require(ggplot2)


URL<- "https://data.nj.gov/resource/iqwc-r2w7.json?record_type=master&calendar_year=2012"
RawData<-fromJSON(URL, nullValue=NA)



Data<- data.frame(payrollid= sapply(RawData,"[[","payroll_id"),
                  fullname = sapply(RawData,"[[","full_name"),
                  salary   = as.numeric(sapply(RawData,"[[","salary_hourly_rate")),
                  dept     = sapply(RawData,"[[","master_department_agency_desc"),
                  section  = sapply(RawData,"[[","master_section_desc"),
                  method   = sapply(RawData,"[[","compensation_method"),
                  year     = sapply(RawData,"[[","calendar_year"),
                  stringsAsFactors = F)


mu  <- mean(Data$salary)
SD  <- sd(Data$salary)
x   <- seq(0,150000,length=10000)
y   <- dnorm(x,mean=mu, sd=SD)
Norm<-data.frame(x=x,y=y)

input<- 93000
pnorm(input, mean=mu, sd=SD)

ggplot(Norm) + 
  aes(x=x,y=y) +
  geom_line(size=1.5) +
  theme_bw() +
  geom_vline(xintercept=input, colour="blue", size=2) +
  labs(title="Distribution of Salaries for New Jersey State Employees")

