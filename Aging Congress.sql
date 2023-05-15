/* Rename party codes to their actual party name using other dataset */
UPDATE data_aging_congress
SET party_code = (
    SELECT party_name
    FROM hsall_parties
    WHERE data_aging_congress.party_code = hsall_parties.party_code
);

/*Rename party code to party name*/
ALTER TABLE data_aging_congress
RENAME COLUMN party_code TO party_name;


/*Calculate Median age by Congress*/
WITH
  age_ranks AS (
    SELECT
      congress,
      age_years,
      ROW_NUMBER() OVER (PARTITION BY congress ORDER BY age_years) AS row_asc,
      ROW_NUMBER() OVER (PARTITION BY congress ORDER BY age_years DESC) AS row_desc
    FROM
      data_aging_congress
  ),
  median_ages AS (
    SELECT
      congress,
      AVG(age_years) AS median_age
    FROM
      age_ranks
    WHERE
      row_asc IN (row_desc, row_desc - 1, row_desc + 1)
    GROUP BY
      congress
  )
SELECT
  congress,
  median_age
FROM
  median_ages
ORDER BY
  congress;
 
 /*Average age of Congress by party */
 SELECT
  party_name,
  AVG(age_years) AS average_age 
FROM
  data_aging_congress
GROUP BY
  party_name;

  /*Average age of Congress by party by congress */
 SELECT
  party_name,
  AVG(age_years) AS average_age,
  congress 
FROM
  data_aging_congress
GROUP BY
  congress,
  party_name;
  