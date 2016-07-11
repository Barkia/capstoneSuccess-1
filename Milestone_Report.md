---
title: "Milestone Report for Data Science Capstone Project"
author: "Vivek Tiwari"
date: "Friday, March 18, 2016"
output: html_document
---

# Summary
The Capstone project for the Coursera Data Science Specialization involves using the [HC Corpora][1] Dataset. The Capstone project is done in collaboration with [Swiftkey][2] and the goal of this project is to design a shiny application with text prediction capabilities. This report will outline the exploratory analysis of the dataset and the current plans for implementing the text prediction algorithm.

---

# Description of Data
The [HC Corpora][1] dataset is comprised of the output of crawls of news sites, blogs and twitter. A readme file with more specific details on how the data was generated can be found [here][3]. The dataset contains 3 files across four languages (Russian, Finnish, German and English). This project will focus on the English language datasets. The names of the data files are as follows:

1. en_US.blogs.txt
2. en_US.twitter.txt
3. en_US.news.txt

The datasets will be referred to as "Blogs", "Twitter" and "News" for the remainder of this report.

---

# Download the data


```r
if(!file.exists("Coursera-SwiftKey.zip")){
    #Download the dataset
    download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip",
                  "Coursera-SwiftKey.zip")
    Download_Date <- Sys.time()
    Download_Date
    #"2016-3-09 04:20:41 IST"
    
    #Unzip the dataset
    unzip("Coursera-SwiftKey.zip")
}else{
    print("Dataset is already downloaded!")
}
```
---

## Bugfix the  News Dataset
There is a minor problem with the News dataset. This was pointed out by a previous student of the course and I have taken it into account. It contains an unusual character on line 77,259. In order to address this issue a small piece of code was written to edit out the character before processing the dataset.


```r
if(!file.exists("./final/en_US/en_US.news_edit.txt")){
    con <- file("./final/en_US/en_US.news.txt", "rb")
    News_Data <- readLines(con)
    close(con)
    #Remove the odd symbol on line 77259
    News_Data <- gsub("\032", "", News_Data, ignore.case=F, perl=T)
    writeLines(News_Data, con=file("./final/en_US/en_US.news_edit.txt"))
    close(con=file("./final/en_US/en_US.news_edit.txt"))
    file.rename("./final/en_US/en_US.news.txt", "./final/en_US.news.txt")
}else{
    con <- file("./final/en_US/en_US.news_edit.txt", "rb")
    News_Data <- readLines(con) 
    close(con)
}
```
---

# Characteristics of Datasets


```r
#Load libraries
library(NLP)
library(tm)
library(stringi)
library(ggplot2)
```

```
## Error in library(ggplot2): there is no package called 'ggplot2'
```

```r
library(RWeka)
```

```
## Error in library(RWeka): there is no package called 'RWeka'
```

```r
library(data.table)

#Generate Corpus for text analysis
cname <- file.path(".", "final", "en_US")
docs <- Corpus(DirSource(cname))
```

The first part of this exploratory analysis is to determine the basic characteristics for each dataset. These
characteristics are shown in the table below.

Dataset  | File Size (bytes) | Number of Lines | Smallest entry | Largest entry
------------- | ------------- | ------------- | ------------- | -------------
Blogs     | 210160014     | 899288 | 1 | 40833 
Twitter   | 167105338  | 2360148 | 2 | 140 
News      | NA     | 1010242 | 1 | 11384 

## Subsetting and Processing the Dataset

Each of the datasets (Blogs, Twitter and News) are large enough that processing time is a factor. In order to address this concern, a representative sampling of each of the datasets was made for the remainder of this analysis. The subset of each file is outlined in the table below.


```r
#Limit Dataset to a random subset of 20% of the data
set.seed(1337)
Subset <- docs
Subset[[1]]$content <- Subset[[1]]$content[as.logical(rbinom(length(Subset[[1]]$content),
                                                             1, prob=0.2))]
Subset[[2]]$content <- Subset[[2]]$content[as.logical(rbinom(length(Subset[[2]]$content),
                                                             1, prob=0.2))]
Subset[[3]]$content <- Subset[[3]]$content[as.logical(rbinom(length(Subset[[3]]$content),
                                                             1, prob=0.2))]
```

Dataset  | File Size (bytes) | Number of Lines | Smallest entry | Largest entry
------------- | ------------- | ------------- | ------------- | -------------
Subset Blogs     | 51951080     | 179180 | 1 | 12409 
Subset Twitter   | 63594736  | 471766 | 3 | 140 
Subset News      | 52384464     | 202308 | 1 | 8949 

Before the subsetted data can be fully analyzed the data needs to be pre-processed to standardize the words and characters from each dataset. An example entry from the Blogs dataset is shown below:


```
## [1] "Point 2: If it’s a show that your kid wants, a show about a book is always better than CRACCC."
```

# Word Frequency



```r
#Plot Word Frequencies
ggplot(wf[wf$freq>60000, ], aes(x=word, y=freq)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=45, hjust=1)) +
    xlab("") +
    ylab("Frequency") +
    ggtitle("Words that appear over 60,000\ntimes in the three Datasets")
```

```
## Error in eval(expr, envir, enclos): could not find function "ggplot"
```

The high frequency for "connecting" words, such as "the", "and", "that" suggests that using a pattern based on word frequency alone will not be sufficient for text prediction. The next analysis looks at common word combinations.

# N-gram Frequency

For brivity the N-gram analysis of this report was limited to 2-grams.


```
## Warning in mclapply(unname(content(x)), termFreq, control): all scheduled
## cores encountered errors in user code
```

```
## Warning in simple_triplet_matrix(i = i, j = j, v = as.numeric(v), nrow =
## length(allTerms), : NAs introduced by coercion
```

```
## Error in simple_triplet_matrix(i = i, j = j, v = as.numeric(v), nrow = length(allTerms), : 'i, j, v' different lengths
```

```
## Error in as.matrix(tdm): object 'tdm' not found
```

```
## Error in data.table(word = names(NgramFreq), freq = NgramFreq): object 'NgramFreq' not found
```


```r
#Plot Word Frequencies
ggplot(WF_Ngram[WF_Ngram$freq>16000, ], aes(x=word, y=freq)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=45, hjust=1)) +
    xlab("") +
    ylab("Frequency") +
    ggtitle("Two Word Combinations (2-grams)that appear\n over 16,000 times in the three Datasets")
```

```
## Error in eval(expr, envir, enclos): could not find function "ggplot"
```

The distribution of 2-grams gives an idea of the prevalence of prepositions in natural language. The text prediction model will have to take this into account.

# Plan

The current plan for the development of the text prediction application will be to use the frequency of 4-grams, 3-grams and 2-grams to estimate the most likely word to follow the entered text. The trick will be to offer valid predictions of N-grams that are not observed within the dataset. In these cases the algorithm will likely default to a list of "non-common" words (i.e. factor out words like the, and, that) and estimate the best possible candidate.

# Session Information
This analysis was performed on a machine with the following characteristics:


```
## R version 3.2.3 (2015-12-10)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 16.04 LTS
## 
## locale:
##  [1] LC_CTYPE=en_IN.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_IN.UTF-8        LC_COLLATE=en_IN.UTF-8    
##  [5] LC_MONETARY=en_IN.UTF-8    LC_MESSAGES=en_IN.UTF-8   
##  [7] LC_PAPER=en_IN.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_IN.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] data.table_1.9.6 stringi_1.0-1    tm_0.6-2         NLP_0.1-9       
## [5] knitr_1.12.3    
## 
## loaded via a namespace (and not attached):
## [1] magrittr_1.5   formatR_1.3    parallel_3.2.3 tools_3.2.3   
## [5] slam_0.1-32    stringr_1.0.0  chron_2.3-47   evaluate_0.9
```

[1]: http://www.corpora.heliohost.org/ "HC Corpora"
[2]: http://swiftkey.com/en/ "Swiftkey"
[3]: http://www.corpora.heliohost.org/aboutcorpus.html "Corpora Readme"
