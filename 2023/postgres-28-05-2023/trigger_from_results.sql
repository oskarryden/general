-- connect to database through psql
psql -h localhost -p 6612 -U oskar -d bangolf

-- add a constraint or trigger that prevents a player from playing the same hole twice in a round
-- https://dba.stackexchange.com/questions/161506/create-a-postgresql-constraint-to-prevent-unique-combination-rows


-- function to create new round from results

-- function to create new table called previous_results from results on update

-- list all user-defined functions
\df

-- create trigger for rounds

-- create trigger for previous results

-- list triggers
\d results;

-- try
insert into results (round_id, player_id, hole_id, score, ymd)
    values (1,1,2,3,'2023-05-28');