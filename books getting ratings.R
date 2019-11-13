# load packages
library(rvest)
library(tidyverse)
library(readxl)
library(RSelenium)
library(xlsx)

# load datasets
books <- read_excel("books w ratings.xlsx", sheet=2)
y <- 2:5
i <- 1
# 1005 books total
# 346 to be redone

# set up 
rD <- rsDriver(browser=c("chrome"), chromever="77.0.3865.40")
driver <- rD$client

# navigate first site
driver$navigate("https://www.goodreads.com/search?utf8=%E2%9C%93&q=Apocrypha%3A+The+Legend+of+BABYMETAL&search_type=books")

# loop starts here
for(i in 1:nrow(books)) {
  tryCatch({
    x <- books[i,1]
    x <- as.character(x)
    
    # search
    element <- driver$findElement(using = "css","#search_query_main")
    element$clearElement()
    element$sendKeysToElement(list(x))
    element$sendKeysToElement(list(key="enter"))
    
    # pause
    t <- sample(y, 1)
    Sys.sleep(t)
    
    # identify first results and take author name
    element <- driver$findElement(using = "css",".minirating")
    rating <- element$getElementText()[[1]]
    
    # log
    books[i,3] <- substr(rating,1,4)
    books[i,4] <- substr(rating,19,nchar(rating)-8)
    
    # print status
    print(i)
  }, error=function(e){cat("Whoops", conditionMessage(e),"\n")})
}

write.xlsx(books,"books w ratings redone.xlsx")

################################################

driver$close()

rD$server$stop()
