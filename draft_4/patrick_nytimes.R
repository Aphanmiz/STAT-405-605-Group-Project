# This file contains the R code for generating the regression plot against
# nytimes covid mentions.

# Libraries.
{
  library(RSQLite)
  library(ggplot2)
  library(stringi)
  library(stringr)
}

# YOUR DATABASE FILEPATH GOES HERE:
# --------------------------------
dbpath = "projectDB.db"
dcon <- dbConnect(SQLite(), dbname = dbpath)
# --------------------------------

### TASK ONE: REGRESS CRASHES AGAINST COVID MENTIONS IN NYTIMES HEADLINES.
{
  # This cell makes a view of numCrashes/month.
  {
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS crashesPerMonth")
    dbSendQuery(conn=dcon, "
      CREATE VIEW crashesPerMonth AS
      SELECT
        SUBSTRING(CRASHDATE, 7, 4) AS Year,
        SUBSTRING(CRASHDATE, 1, 2) AS Month,
        count(*) AS numCrashes
      FROM tableCrashes
      GROUP BY Year, Month
    ")
  }
  
  # This cell does string search on nytimes.
  # Makes view containing numMentions/month.
  # Only searches in TITLE and ABSTRACT.
  {
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS mentionsCount")
    dbSendQuery(conn=dcon, "
      CREATE VIEW mentionsCount AS
      SELECT pub_date
      FROM tableNYT
      WHERE
        abstract LIKE '%COVID%' OR abstract LIKE '%virus%' OR abstract LIKE '%pandemic%'
      OR
        headline LIKE '%COVID%' OR headline LIKE '%virus%' OR headline LIKE '%pandemic%'
    ")
    
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS mentionsPerMonth")
    dbSendQuery(conn=dcon, "
      CREATE VIEW mentionsPerMonth AS
      SELECT
        SUBSTRING(pub_date, 1, 4) AS Year,
        SUBSTRING(pub_date, 6, 2) AS Month,
        count(*) AS numMentions
      FROM mentionsCount
      GROUP BY Year, Month
    ")
  }
  
  # This cell joins all of the above info to create a df to be used for regression.
  {
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS articlesPerMonth") 
    dbSendQuery(conn=dcon, "
    CREATE VIEW articlesPerMonth AS
    SELECT
      SUBSTRING(pub_date, 1, 4) AS Year,
      SUBSTRING(pub_date, 6, 2) AS Month,
      count(*) AS numArticles
    FROM tableNYT
    GROUP BY Year, Month
    ")
    
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS propMentions")
    dbSendQuery(conn=dcon, "
    CREATE VIEW propMentions AS
    SELECT
      a.Year AS Year,
      a.Month AS month,
      c.numCrashes,
      a.numMentions AS numMentions,
      b.numArticles AS numArticles,
      CAST(a.numMentions AS FLOAT)/CAST(b.numArticles AS FLOAT) AS propMentions
    FROM
      mentionsPerMonth a,
      articlesPerMonth b,
      crashesPerMonth c
    WHERE
      a.Year = b.Year AND a.Month = b.Month AND
      a.Year = c.Year AND a.Month = c.Month
    ORDER BY Year, Month
    ")
    
    res <- dbSendQuery(conn=dcon, "
      SELECT * FROM propMentions 
    ")
    Crashes.Vs.Mentions <- dbFetch(res, -1)
    dbClearResult(res)
  }
  
  # This cell does linear regression and ggplots results.
  {
    # Make and fit model
    linear.model <- lm(numCrashes ~ propMentions, data=Crashes.Vs.Mentions)
    lm.intercept = linear.model$coefficients[1] # p = 2E-16 ***
    lm.slope = linear.model$coefficients[2] # p = 3.69E-16 ***
    summary(linear.model)
    
    # Plot things
    ggplot(data=Crashes.Vs.Mentions) +
      geom_point(aes(x=propMentions, y=numCrashes)) + # Plot points
      geom_abline(intercept=lm.intercept, slope=lm.slope, col="red") + # Plot lm
      ggtitle("COVID keywords vs num crashes in each month",
              subtitle="2018-2021, 1 point = 1 month") +
      xlab("Proportion of articles with COVID-related keywords/month") +
      ylab("Number of crashes/month")
      
  }
  
  # After you are done, run this cell to drop views and clean up your database :)
  {
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS crashesPerMonth")
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS mentionsCount")
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS mentionsPerMonth")
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS articlesPerMonth") 
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS propMentions")
  }
}

### TASK TWO: RIBBON PLOT FOR MONTHLY DATA.
{
  # This cell aggregates tableCrashes into a nice df for the ribbon plot.
  {
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS crashesPerDay")
    dbSendQuery(conn=dcon, "
        CREATE VIEW crashesPerDay AS
        SELECT
          SUBSTRING(CRASHDATE, 7, 4) AS Year,
          SUBSTRING(CRASHDATE, 1, 2) AS Month,
          SUBSTRING(CRASHDATE, 4, 2) AS Day,
          COUNT(*) AS numCrashes
        FROM tableCrashes
        GROUP BY Year, Month, Day
      ")
    
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS crashesMinMaxAvg")
    dbSendQuery(conn=dcon, "
        CREATE VIEW crashesMinMaxAvg AS
        SELECT
          Year, Month,
          MIN(numCrashes) AS min,
          MAX(numCrashes) AS max,
          AVG(numCrashes) AS avg
        FROM crashesPerDay
        GROUP BY Year, Month
        ORDER BY Year, Month
      ")
    
    res <- dbSendQuery(conn=dcon, "
        SELECT * FROM crashesMinMaxAvg
      ")
    dfRibbon <- dbFetch(res, -1)
    dbClearResult(res)
  }
  
  # This cell makes the ribbon plot.
  {
    # Add indices to df.
    dfRibbon$index = 1:nrow(dfRibbon)
    
    # Make plot.
    ggplot(data=dfRibbon) +
      geom_line(aes(x=index, y=avg), col="red") + # Line in red
      geom_ribbon(aes(x=index, ymin=min, ymax=max), alpha=0.5) + # Ribbon
      ggtitle("Time vs. Number of Crashes.",
              subtitle="min, max, and avg crashes/month displayed.") +
      xlab("Time") + ylab("Crash stats") +
      scale_x_continuous(breaks=c(7, 31, 55, 79, 103, 127),
                         labels=c("2013", "2015", "2017", "2019", "2021", "2023"))
  }
  
  # After you are done, run this cell to drop views and clean up your database :)
  {
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS crashesPerDay")
    dbSendQuery(conn=dcon, "DROP VIEW IF EXISTS crashesMinMaxAvg")
  }
}


