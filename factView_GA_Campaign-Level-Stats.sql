CREATE OR REPLACE TABLE `rare-deployment-311310.factView_GA.factView_GA_Campaign-Level-Stats` AS


WITH cs AS (
    SELECT
      _LATEST_DATE,
      _DATA_DATE AS Date,
      campaign_id AS CampaignId,
      segments_device AS Device,
      metrics_impressions AS Impressions,
      metrics_clicks AS Clicks,
      metrics_conversions AS Conversions,
      metrics_conversions_value AS ConversionValue,
      metrics_cost_micros/1000000 AS Cost,
    FROM
    `rare-deployment-311310.GA_GoogleAdsTransfer.ads_CampaignBasicStats_3421151639`
)

SELECT
  cs.Date,
  c.RestaurantId,
  bg.shortName AS Name,
  c.ExternalCustomerId,
  c.CampaignName,
  c.CampaignStatus,
  c.CampaignType,
  c.Country,
  c.BiddingStrategy,
  bg.kitchenType AS KitchenType,
  bg.landingPage AS LandingPage,
  bg.region AS Region,
  bg.isActive AS isActive,
  bg.approvalStatus AS ApprovalStatus,
  bg.domainHealth AS DomainHealth,
  bg.onVacation AS onVacation,
  bg.canDeliver AS Delivery,
  bg.hasFlatDiscount AS FlatDiscount,
  bg.hasOffer AS OfferDiscount,
  cs.Device,
  pc.PacingCategory,
  db.LiveStatus AS HistoricalLiveStatus,
  lc.LiveCount,
  CASE
        WHEN bg.country LIKE "%Poland%" THEN "AppSmart not yet Live"
        WHEN bg.country LIKE "%Switzerland%" THEN "AppSmart not yet Live"
        WHEN REGEXP_CONTAINS(bg.ExternalRPId,"AppSmart") AND SAFE_CAST(rs.Recommended_spend AS STRING) IS NULL THEN "AppSmart not yet Live"
        WHEN REGEXP_CONTAINS(bg.ExternalRPId,"AppSmart") AND SAFE_CAST(rs.Recommended_spend AS STRING) LIKE "0.00" THEN "0 Recommended Spend"
        WHEN REGEXP_CONTAINS(bg.ExternalRPId,"AppSmart") AND SAFE_CAST(rs.Recommended_spend AS STRING) NOT LIKE "0.00" THEN SAFE_CAST(rs.Recommended_spend AS STRING)
        WHEN bg.ExternalRPId IS NULL AND SAFE_CAST(rs.Recommended_spend AS STRING) IS NULL THEN "No Recommended Spend"
        WHEN bg.ExternalRPId IS NULL AND SAFE_CAST(rs.Recommended_spend AS STRING) LIKE "0.00" THEN "0 Recommended Spend" ELSE SAFE_CAST(rs.Recommended_spend AS STRING) END 
  AS RecommendedSpendStatus,
  CASE
        WHEN bg.ExternalRPId IS NULL THEN "North"
        WHEN bg.ExternalRPId IS NOT NULL THEN "South" END
  AS BusinessUnit,
  CASE
        WHEN bg.restaurantId IS NULL THEN ""
        WHEN bg.country LIKE "%Poland%" THEN "AppSmart not yet Live"
        WHEN bg.country LIKE "%Switzerland%" THEN "AppSmart not yet Live"
        WHEN bg.ExternalRPId IS NOT NULL AND rs.Recommended_spend IS NULL THEN "AppSmart not yet Live"
        WHEN SAFE_CAST(rs.Recommended_spend AS STRING) LIKE "0.00" THEN "0recommendedSpend" 
        WHEN NOT REGEXP_CONTAINS(bg.landingPage,r'\.') THEN "noLandingPage" 
        WHEN REGEXP_CONTAINS(bg.kitchenType,"Alcohol") THEN "isAlcohol" 
        WHEN bg.isActive = FALSE THEN "notActive" 
        WHEN bg.onVacation = TRUE THEN "onVacation"
        WHEN bg.approvalStatus LIKE "%DISAPPROVED%" THEN "disapprovedStatus" 
        ELSE "Live" END 
  AS LiveStatus,
  rs.Group AS GAGroup,
  rs.Recommended_spend AS RecommendedSpend,
  cv.CurrencyValue,
  cs.Impressions,
  cs.Clicks,
  cs.Conversions,
  cs.ConversionValue,
  cs.Cost,


FROM
  cs AS cs


-- LJ #1
  LEFT JOIN (
      SELECT
        _LATEST_DATE,
        _DATA_DATE AS Date,
        CASE
              WHEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) LIKE "%Performance Max%" 
                  THEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){4}([^|]+)'))
              WHEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) LIKE "%Non-Core - Search%" 
                  THEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){4}([^|]+)'))
              WHEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) LIKE "%Non-Core - RMT%" 
                  THEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){4}([^|]+)'))
              WHEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) LIKE "%Core - Search%" 
                  THEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){4}([^|]+)'))
              WHEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) LIKE "%Core - RMT%" 
                  THEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){4}([^|]+)')) 
              WHEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) IS NOT NULL 
                THEN TRIM(REGEXP_EXTRACT(campaign_name,r'^(?:[^|]+\|){2}([^|]+)')) END 
        AS RestaurantID,
        customer_id AS ExternalCustomerId,
        campaign_id AS CampaignId,
        campaign_name AS CampaignName,
        CASE
              WHEN campaign_name LIKE "% UK |%" THEN "UK"
              WHEN campaign_name LIKE "% DK |%" THEN "DK"
              WHEN campaign_name LIKE "% DK -%" THEN "DK"
              WHEN campaign_name LIKE "%DK -%" THEN "DK"
              WHEN campaign_name LIKE "%DK Local%" THEN "DK"
              WHEN campaign_name LIKE "% IE |%" THEN "IE"
              WHEN campaign_name LIKE "% DE |%" THEN "DE"
              WHEN campaign_name LIKE "% AT |%" THEN "AT"
              WHEN campaign_name LIKE "% PL |%" THEN "PL"
              WHEN campaign_name LIKE "% CH |%" THEN "CH" END 
        AS Country,
        CASE
              WHEN campaign_name LIKE "%| DSA |%" THEN "DSA"
              WHEN campaign_name LIKE "%| Non-Core %" THEN "Non-Core"
              WHEN campaign_name LIKE "%| Core %" THEN "Core"
              WHEN campaign_name LIKE "%| Performance Max %" THEN "Performance Max" END 
        AS CampaignType,
        campaign_bidding_strategy_type AS BiddingStrategy,
        campaign_status AS CampaignStatus,
      FROM
        `rare-deployment-311310.GA_GoogleAdsTransfer.ads_Campaign_3421151639`
  ) c
    ON c.CampaignId = cs.CampaignId

-- LJ #2
  LEFT JOIN
    `rare-deployment-311310.dimView_NS.dimView_NS_SEM-Feed` bg
    ON
       SAFE_CAST(bg.restaurantId AS STRING) = c.RestaurantId

-- LJ #3
  LEFT JOIN
    `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status`  pc
    ON 
      SAFE_CAST(pc.RestaurantId AS STRING) = c.RestaurantId AND pc.Date = CURRENT_DATE()-1


-- LJ #4
  LEFT JOIN
    `rare-deployment-311310.dimView_GA.dimView_GA_Recommended-Spend` rs
    ON 
      SAFE_CAST(rs.Restaurant_Partner_Key AS STRING) = c.RestaurantId

-- LJ #5
  LEFT JOIN
    `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db
    ON
      db.RestaurantId = c.RestaurantId AND db.Date = cs.Date


-- LJ #6
  LEFT JOIN (
    SELECT
      db.Date,
      SUM(CASE WHEN db.LiveStatus = "Live" THEN 1 ELSE 0 END) AS LiveCount
    FROM
      `rare-deployment-311310.dimView_GA.dimView_GA_Restaurant-Partners-Status` db
    GROUP BY 
      db.Date
  ) lc
    ON lc.Date = cs.Date


-- LJ #7
  LEFT JOIN
    `rare-deployment-311310.dimView_NS.dimView_NS_Currency-Value` cv
    ON
      cv.Market = c.Country    

WHERE
  c.Date= c._LATEST_DATE
  AND
  cs.Date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -410 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)


