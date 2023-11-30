CREATE OR REPLACE TABLE `rare-deployment-311310.factView_GA.factView_GA_Restaurant-Level-Stats` AS

SELECT
  rpd.RestaurantID,
  SAFE_CAST(rpd.RestaurantID AS INT64) AS RestaurantIDINT,
  rpd.Date,
  rpd.WeekdayName,
  DATE_TRUNC(date(rpd.Date), month) AS MonthStartDate,
  CASE
    WHEN EXTRACT(YEAR FROM rpd.Date) <>  EXTRACT(YEAR FROM CURRENT_DATE) THEN FALSE
    WHEN DATE_TRUNC(date(rpd.Date), month) = DATE_TRUNC(date(CURRENT_DATE()), month) THEN TRUE ELSE FALSE END 
  AS isCurrentMonth,
  CASE 
      WHEN DATE_DIFF(CURRENT_DATE(), rpd.Date, DAY) > 7 THEN FALSE ELSE TRUE END
  AS isLast7Days,
  DATE_TRUNC(date(rpd.Date), WEEK(MONDAY)) AS WeekStartDate,
  rpd.Year,
  rpd.Country,
  bg.shortName AS Name,
  bg.landingPage AS LandingPage,
  bg.region AS Region,
  bg.onVacation AS onVacation,
  bg.canDeliver AS Delivery,
  bg.hasFlatDiscount AS FlatDiscount,
  bg.hasOffer AS OfferDiscount,
  db.GAGroup,
  pc.PacingCategory,
  cv.CurrencyValue,
  CASE
    WHEN bg.ExternalRpId LIKE "%AppSmart%" THEN "South"
    ELSE "North"
    END AS rpSource,
  db.LiveStatus AS LiveStatusHistorical,
  CASE
    WHEN bg.country LIKE "%Poland%" THEN "AppSmart not yet Live"
    WHEN bg.country LIKE "%Switzerland%" THEN "AppSmart not yet Live"
    WHEN REGEXP_CONTAINS(bg.ExternalRPId,"AppSmart") AND rcs.Recommended_spend IS NULL THEN "AppSmart not yet Live"
    WHEN bg.ExternalRPId LIKE "%KingFood%" THEN "KingFood not yet Live" 
    WHEN CAST(rcs.Recommended_spend AS STRING) LIKE "0" THEN "0recommendedSpend" 
    WHEN CAST(rcs.Recommended_spend AS STRING) LIKE "0.00" THEN "0recommendedSpend" 
    WHEN NOT REGEXP_CONTAINS(bg.landingPage,r'\.') THEN "noLandingPage" 
    WHEN REGEXP_CONTAINS(bg.kitchenType,"Alcohol") THEN "isAlcohol" 
    WHEN bg.isActive = FALSE THEN "notActive" 
    WHEN bg.onVacation = TRUE THEN "onVacation"
    WHEN bg.approvalStatus  LIKE "%DISAPPROVED%" THEN "disapprovedStatus"
    WHEN bg.restaurantId IS NULL THEN "Dead"
    ELSE "Live"
  END AS LiveStatusActual,
  bs.CurrentBiddingStrategy,
  rpd.TotalWeekDayOccurrences,
  IFNULL(SUM(c.Impressions),0) AS Impressions,
  IFNULL(SUM(c.Clicks),0) AS Clicks,
  IFNULL(SUM(c.Conversions),0) AS Conversions,
  IFNULL(SUM(c.ConversionValue),0) AS ConversionValue,
  IFNULL(SUM(c.Cost),0) AS Cost,
  AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) AS RecommendedSpend, 
  AVG(rcs.Recommended_spend) AS RecommendedSpendCurrent, 
  CASE
        WHEN rpd.Country = "UK" AND ((IFNULL(SUM(c.Impressions),0) > 0 AND db.liveStatus <> "Live") OR (db.liveStatus = "Live" AND AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) > 0)) THEN
          IF(rpd.TotalWeekDayOccurrences = 0, 0,
          IF(SEARCH(rpd.weekdayName,"Monday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.0961/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Tuesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.0950/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Wednesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1000/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Thursday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1134/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Friday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.2059/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Saturday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.2332/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Sunday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1564/rpd.TotalWeekDayOccurrences),0))))))))
        WHEN rpd.Country = "DE" AND ((IFNULL(SUM(c.Impressions),0) > 0 AND db.liveStatus <> "Live") OR (db.liveStatus = "Live" AND AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) > 0)) THEN
          IF(rpd.TotalWeekDayOccurrences = 0, 0,
          IF(SEARCH(rpd.weekdayName,"Monday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1092/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Tuesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1151/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Wednesday"),AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1180/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Thursday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1220/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Friday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1562/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Saturday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1727/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Sunday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.2068/rpd.TotalWeekDayOccurrences),0))))))))
        WHEN rpd.Country = "AT" AND ((IFNULL(SUM(c.Impressions),0) > 0 AND db.liveStatus <> "Live") OR (db.liveStatus = "Live" AND AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) > 0)) THEN
          IF(rpd.TotalWeekDayOccurrences = 0, 0,
          IF(SEARCH(rpd.weekdayName,"Monday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1009/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Tuesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1036/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Wednesday"),AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1269/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Thursday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1420/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Friday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1479/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Saturday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1788/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Sunday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1998/rpd.TotalWeekDayOccurrences),0))))))))
        WHEN rpd.Country = "DK" AND ((IFNULL(SUM(c.Impressions),0) > 0 AND db.liveStatus <> "Live") OR (db.liveStatus = "Live" AND AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) > 0)) THEN
          IF(rpd.TotalWeekDayOccurrences = 0, 0,
          IF(SEARCH(rpd.weekdayName,"Monday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1025/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Tuesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1113/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Wednesday"),AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1097/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Thursday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1327/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Friday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1945/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Saturday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1968/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Sunday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1525/rpd.TotalWeekDayOccurrences),0))))))))
        WHEN rpd.Country = "IE" AND ((IFNULL(SUM(c.Impressions),0) > 0 AND db.liveStatus <> "Live") OR (db.liveStatus = "Live" AND AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) > 0)) THEN
          IF(rpd.TotalWeekDayOccurrences = 0, 0,
          IF(SEARCH(rpd.weekdayName,"MONDAY"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.0933/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"TUESDAY"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.0939/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"WEDNESDAY"),AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1006/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"THURSDAY"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1148/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"FRIDAY"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.2006/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"SATURDAY"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.2283/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"SUNDAY"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1685/rpd.TotalWeekDayOccurrences),0))))))))
        WHEN (rpd.Country = "PL" OR rpd.Country = "CH")  AND ((IFNULL(SUM(c.Impressions),0) > 0 AND db.liveStatus <> "Live") OR (db.liveStatus = "Live" AND 
        AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64)) > 0)) THEN
          IF(rpd.TotalWeekDayOccurrences = 0, 0,
          IF(SEARCH(rpd.weekdayName,"Monday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.0985/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Tuesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.0996/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Wednesday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1037/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Thursday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1179/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Friday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1996/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Saturday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.2201/rpd.TotalWeekDayOccurrences),
          IF(SEARCH(rpd.weekdayName,"Sunday"), AVG(SAFE_CAST(rs.RecommendedSpend AS FLOAT64))*(0.1606/rpd.TotalWeekDayOccurrences),0)))))))) 
      END
    AS ForecastedSpend,


#FROM TABLE

FROM (
    SELECT 
    a.restaurantID AS RestaurantId,
    a.Date,
    a.Country,
    a.TableKey,
    DATE_TRUNC(date(a.Date), month) AS MonthStartDate,
    DATE_TRUNC(date(a.Date), WEEK(MONDAY)) AS WeekStartDate,
    UPPER(FORMAT_DATE('%A', a.Date)) AS WeekdayName,
    EXTRACT(YEAR FROM a.Date) AS Year,
    c.weekDayOccurrences AS WeekDaysOccurrences,
    IF(a.Date > DATE(2023,01,08), IFNULL(ct.CountLiveWeekDays,0),c.weekDayOccurrences) AS WeekDaysLiveCount,
    ga.Impressions,
    db.LiveStatus,

    IF(DATE_TRUNC(date(a.Date), month) = DATE_TRUNC(date(CURRENT_DATE), month),
      c.weekDayOccurrences + IF(a.Date > DATE(2023,01,08), IFNULL(ct.CountLiveWeekDays,0),c.weekDayOccurrences),
    IF(DATE_TRUNC(date(a.Date), month) <> DATE_TRUNC(date(CURRENT_DATE), month) AND c.weekDayOccurrences = IF(a.Date > DATE(2023,01,08), IFNULL(ct.CountLiveWeekDays,0),c.weekDayOccurrences),
      c.weekDayOccurrences,
    IF(DATE_TRUNC(date(a.Date), month) <> DATE_TRUNC(date(CURRENT_DATE), month) AND c.weekDayOccurrences > IF(a.Date > DATE(2023,01,08), IFNULL(ct.CountLiveWeekDays,0),c.weekDayOccurrences) AND ga.Impressions > 0 AND db.liveStatus <> "Live",
        c.weekDayOccurrences,
    IF(DATE_TRUNC(date(a.Date), month) <> DATE_TRUNC(date(CURRENT_DATE), month) AND c.weekDayOccurrences > IF(a.Date > DATE(2023,01,08), IFNULL(ct.CountLiveWeekDays,0),c.weekDayOccurrences), 
      IF(a.Date > DATE(2023,  01,08), IFNULL(ct.CountLiveWeekDays,c.weekDayOccurrences),c.weekDayOccurrences),
      0)))) 
    AS TotalWeekDayOccurrences,

    FROM(
      SELECT
        ga.RestaurantID,
        ga.Date, 
        ga.Country,
        CONCAT(ga.RestaurantID,"|",ga.Date) AS TableKey,

      FROM `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` ga

      WHERE ga.Date IS NOT NULL

      UNION DISTINCT  
        SELECT restaurantID, Date, Country, CONCAT(restaurantID,"|",Date) 
        FROM `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db
        WHERE Date IS NOT NULL AND restaurantID IS NOT NULL
    ) a


      LEFT JOIN
      `rare-deployment-311310.dimView_NS.dimView_NS_WeekDayOccurrences` c
      ON (DATE_TRUNC(date(a.Date), month)  = c.Month AND UPPER(FORMAT_DATE('%A', a.Date)) = c.weekDayName)


      LEFT JOIN (
        SELECT 
            db.RestaurantId,
            CONCAT(UPPER(FORMAT_DATE('%A', db.Date)),"|",DATE_TRUNC(date(db.Date), month)) AS TableKey,
            COUNTIF(
              SEARCH(db.LiveStatus,"Live") OR 
              (
                (NOT(SEARCH(db.RecommendedSpendStatus,"AppSmart not yet Live")) 
                OR NOT(SEARCH(db.RecommendedSpendStatus,"AppSmart not yet Live")) 
                OR NOT(SEARCH(db.RecommendedSpendStatus,"0 Recommended Spend"))) 
                AND ga.Impressions > 0
              )
            ) 
            AS CountLiveWeekDays,
            DATE_TRUNC(date(db.Date), month) AS MonthStartDate,
            UPPER(FORMAT_DATE('%A', db.Date)) As WeekDayName,

          FROM 
          `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db

          LEFT JOIN 
            (SELECT ga.RestaurantID, ga.Date, SUM(ga.Impressions) AS Impressions
              FROM `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` ga
              GROUP BY 1, 2) ga
          ON ga.RestaurantID = db.RestaurantId AND ga.Date = db.Date
        
          GROUP BY 1, 2, 4, 5
      ) ct
      ON CONCAT(a.RestaurantId,"|",DATE_TRUNC(date(a.Date), month),"|",UPPER(FORMAT_DATE('%A', a.Date))) = CONCAT(ct.RestaurantId,"|",ct.MonthStartDate,"|",ct.WeekDayName) 

      LEFT JOIN 
        (SELECT ga.RestaurantID, ga.Date, SUM(ga.Impressions) AS Impressions
          FROM `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` ga
          GROUP BY 1, 2) ga
      ON ga.RestaurantID = a.restaurantId AND ga.Date = a.Date

      LEFT JOIN 
          (SELECT db.RestaurantId, db.Date, db.LiveStatus 
          FROM `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db) db
      ON a.restaurantId = db.RestaurantId AND a.Date = db.Date

      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13

) rpd


#LEFT JOIN TABLES

  #1 c
        LEFT JOIN 
                `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` 
          c
          ON
            rpd.RestaurantID = c.RestaurantID AND rpd.Date = c.Date



  #2 bg
        LEFT JOIN
            `rare-deployment-311310.dimView_NS.dimView_NS_SEM-Feed` 
          bg
            ON
              rpd.RestaurantID = SAFE_CAST(bg.restaurantId AS STRING)


  #3 pc
        LEFT JOIN
                `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` 
          pc
            ON
              rpd.restaurantID = SAFE_CAST(pc.RestaurantId AS STRING) AND rpd.Date = pc.Date


  #4 rs
        LEFT JOIN (
                SELECT
                  RestaurantId,
                  Date,
                  RecommendedSpend,
                  LiveStatus
                  FROM
                    `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db
                  WHERE
                    1=1 QUALIFY ROW_NUMBER() OVER (PARTITION BY RestaurantId, DATE_TRUNC(DATE(Date), month)
                    ORDER BY
                      Date DESC) = 1
                  ) 
          rs
            ON
              rpd.RestaurantID = rs.RestaurantId AND DATE_TRUNC(date(rpd.Date), month) = DATE_TRUNC(date(rs.Date), month)   



  #5 db
        LEFT JOIN
                `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` 
          db
            ON
              rpd.RestaurantID = db.RestaurantId AND rpd.Date = db.Date



  #6 ld
        LEFT JOIN (
                  SELECT 
                  db.restaurantID AS RestaurantId,
                  DATE_TRUNC(date(db.Date), month) AS MonthStartDate,
                  COUNTIF(
                    SEARCH(db.liveStatus,"Live") OR 
                    (
                      (NOT(SEARCH(db.recommendedSpendStatus,"AppSmart not yet Live")) 
                      OR NOT(SEARCH(db.recommendedSpendStatus,"AppSmart not yet Live")) 
                      OR NOT(SEARCH(db.recommendedSpendStatus,"0 Recommended Spend"))) 
                      AND ga.Impressions > 0
                    )
                  ) AS WeekDaysLiveCount,

                  FROM 
                  `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db

                  LEFT JOIN 
                          (SELECT ga.RestaurantID, ga.Date, SUM(ga.Impressions) AS Impressions
                            FROM `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` ga
                            GROUP BY 1, 2) 
                    ga
                      ON 
                        ga.RestaurantID = db.restaurantId AND ga.Date = db.Date
                
                  GROUP BY 1, 2
                )
          ld
            ON
              rpd.RestaurantID = ld.RestaurantId AND rpd.MonthStartDate = ld.MonthStartDate


  #7 cv
        LEFT JOIN
                `rare-deployment-311310.dimView_NS.dimView_NS_Currency-Value` 
          cv
            ON
              rpd.Country = cv.Market

  
  #8 rcs
        LEFT OUTER JOIN
        `rare-deployment-311310.dimView_GA.dimView_GA_Recommended-Spend` 
          rcs
            ON
              rpd.RestaurantId = SAFE_CAST(rcs.Restaurant_Partner_Key AS STRING)
  
  #9 bs
        LEFT JOIN (
                SELECT
                  RestaurantId,
                  Date,
                  STRING_AGG(DISTINCT(BiddingStrategy)) AS CurrentBiddingStrategy
                  FROM
                    `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` ga
                  WHERE
                    ga.Date = CURRENT_DATE()-1
                  GROUP BY 1,2
                  ) 
          bs
            ON
              rpd.RestaurantID = bs.RestaurantId   





WHERE
  DATE_DIFF(CURRENT_DATE(), rpd.Date, YEAR) < 2 AND rpd.RestaurantId IS NOT NULL

GROUP BY
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25

ORDER BY
  RestaurantID ASC, Date DESC
