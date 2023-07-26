------ TABLE PROCRESS
.open restaurant.db

DROP TABLE food;
CREATE TABLE  food (
  food_id int,
  food_name text,
  food_cost int,
  point int
);
  
INSERT INTO food VALUES 
  (1, "banana_chip", 20, 1),
  (2, "hamberg", 100, 8),
  (3, "noodle", 45, 3),
  (4, "fired_rice", 85, 6);


DROP TABLE beverage;
CREATE TABLE IF NOT EXISTS beverage (
  beverage_id int,
  beverage_name text,
  beverage_cost int,
  point int
);

INSERT INTO beverage VALUES
  (1, "coffee", 35, 2),
  (2, "water", 10, 3),
  (3, "cocoa", 40, 2),
  (4, "greentea", 30, 1);

DROP TABLE desert;
CREATE TABLE IF NOT EXISTS desert (
  desert_id int,
  desert_name text,
  desert_cost int,
  point int
);

INSERT INTO desert VALUES
  (1, "pudding",15,1),
  (2, "cake",45,6),
  (3, "pingsu",50,3),
  (4, "brownie",10,2);

CREATE TABLE IF NOT EXISTS branch (
  branch_id int,
  branch_name text
);

INSERT INTO branch VALUES
  (1,"BKK"),
  (2,"NKP"),
  (3,"cnx"),
  (4,"phk");

DROP TABLE member;
  
CREATE TABLE IF NOT EXISTS member (
  member_id int,
  member_name text,
  branch_id int,
  food_id int,
  desert_id int,
  beverage_id int
);
INSERT INTO member VALUES
  (01,"ax",1,2,1,3),
  (02,"bx",2,2,2,1),
  (03,"cx",3,2,3,4),
  (04,"dx",1,1,1,2);

.mode box
.header on
/*SELECT * FROM food limit 4*/
------ SELECT PROCESS
 WITH information AS (
  SELECT DISTINCT
    member_name,
    branch.branch_name AS branch,
    food.food_name AS food,
    desert.desert_name AS desert,
    beverage.beverage_name AS beverage
  FROM member
  JOIN branch ON member.branch_id = branch.branch_id
  JOIN food ON member.food_id = food.food_id
  JOIN desert ON member.desert_id = desert.desert_id
  JOIN beverage ON member.beverage_id = beverage.beverage_id
),
membership AS (
  SELECT DISTINCT
    member_name,
    food.point + desert.point + beverage.point AS total_point,
    food.food_cost + desert.desert_cost + beverage.beverage_cost AS total_bill
  FROM information
  JOIN food ON information.food = food.food_name
  JOIN desert ON information.desert = desert.desert_name
  JOIN beverage ON information.beverage = beverage.beverage_name
),

fullscore AS (SELECT distinct
  information.member_name,
  information.branch,
  information.food,
  information.desert,
  information.beverage,
  membership.total_point,
  membership.total_bill,
  (CASE WHEN membership.total_point > 10 
  THEN "freegift" 
  ELSE "nonegift" 
  END) AS member_status,
  (CASE WHEN membership.total_bill IS NOT NULL 
  THEN CAST(membership.total_bill/10 AS INT)
  ELSE NULL
  END) AS bonus
FROM information
JOIN membership ON information.member_name = membership.member_name)

-----------------------

  SELECT *,
  fullscore.bonus + fullscore.total_point AS collectpoint
FROM fullscore
ORDER BY collectpoint DESC
