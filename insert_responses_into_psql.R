# A script to insert test responses into the current active baseline database
# takes in a csv file with all the columns from the responses table
options(warn=-1)
#suppress messages when loading package
library(readr)
library(DBI)
library(RPostgreSQL)

# Get the credentials for the baseline database from env variables
bl_db_name = Sys.getenv("BASELINE_DATABASE_NAME")
bl_db_host = Sys.getenv("BASELINE_DATABASE_HOST")
bl_db_user = Sys.getenv("BASELINE_DATABASE_USER")
bl_db_passwd = Sys.getenv("BASELINE_DATABASE_PASSWORD")
bl_db_port = Sys.getenv("BASELINE_DATABASE_PORT")

# Create a database connection object with the credentials above 
pg <- dbDriver("PostgreSQL")
conn <-  dbConnect(
	pg,
	dbname= bl_db_name,
	host= bl_db_host,
	port= bl_db_port,
	user= bl_db_user,
	password= bl_db_passwd
	)

# Function to insert the contents of the responses csv file into the responses table on baseline
insert_responses <- function(input_file, db_conn){
	# Read the csv file containing the responses
	responses_df <- read.csv(
		input_file,
		stringsAsFactors = FALSE)
	
	# Write the responses to the responses table in the baseline db
	dbWriteTable(
		db_conn,
		"responses",
		responses_df,
		append = TRUE,
		row.names = FALSE
		)

	# disconnect from the database
	dbDisconnect(conn)
}

# Accept command line arguments and store them in the input variable
input<- commandArgs(TRUE)

# Call the insert_responses function passing in the command line arg and the db connection object
insert_responses(input, conn)
