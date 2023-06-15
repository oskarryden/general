library(DBI)
library(RPostgreSQL)

# Connect to the database, the syntax is:
# dbConnect(drv, ...)   # where drv is the driver object
# and ... are driver-specific parameters

# Database connection parameters
db <- "bangolf"
host <- "localhost"
port <- 6612
username <- "oskar"

dbc <- DBI::dbConnect(
    drv = dbDriver("PostgreSQL"),
    dbname="bangolf",
    host="localhost",
    port=6612,
    user="oskar")

DBI::dbSendQuery(dbc, "create table spelare (id serial primary key, namn varchar(50))")
DBI::dbSendQuery(dbc, "alter table spelare rename column id to player_id;")
DBI::dbSendQuery(dbc, "alter table holes rename column course_id to hole_id;")
DBI::dbSendQuery(dbc, "alter table courses rename to holes;")

# Insert data for courses
courses <- data.frame(
    course_id = seq(1, 18, by = 1),
    par = rep(2, 18))

# Write the data to the database
DBI::dbWriteTable(dbc, "courses", courses, row.names = FALSE)

# create constraints
DBI::dbSendQuery(dbc,
    "alter table results
    add constraint hole_constraint
    foreign key (hole_id)
    references holes (hole_id);")

