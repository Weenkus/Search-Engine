class SearchPageController < ApplicationController
  def home
  end
  
  def help
  end
  
  def anal
  end
  
  def analQuery
    # Fatch all the touples from DB that are between the two user specified dates
	startDate = "'" + params[:start_date]["year"] + "-" + params[:start_date]["month"] + "-" + params[:start_date]["day"] + "'"
	endDate = "'" + params[:end_date]["year"] + "-" + params[:end_date]["month"] + "-" + params[:end_date]["day"] + "'"    

    # Format the data so it matches the user's granulation choice
    if params[:time] == "day"
		filter = "created_at::DATE as days"
		groupBy = "days"
		orderBy = "1, 2"
	elsif params[:time] == "hour"
		filter = "date_trunc('hour', created_at) as hours"
		groupBy = "hours"
		orderBy = "1, 2"
	end
	
	# Execute the sql
	if params[:time] == "day" || params[:time] == "hour"
		
		sqlRecords = "SELECT search, " + filter + ", COUNT(*) AS count FROM records WHERE created_at::DATE >= " + startDate + " AND created_at::DATE <= " + endDate
		sqlRecords = sqlRecords + " GROUP BY search, " + groupBy + " ORDER BY " + orderBy
				
		# DROP TEMP PREPIVOT
		#sqlDrop = "DROP TABLE prepivot"
		#ActiveRecord::Base.connection.execute(sqlDrop).values		
				
		# CREATE TEMP TABLE
		createTemp = "CREATE TEMP TABLE prePivot as " + sqlRecords
		ActiveRecord::Base.connection.execute(createTemp)
		
		# CREAT data types for the pivoted table
		@datesForHTML = Array.new
		@datesForHTML << "Query"
		dataTypeString = "as ct(query varchar(250)"

		# Pivot the relation
		if params[:time] == "day"
			# GET ALL THE DATES
			grepDates = "SELECT days FROM prePivot"
			dates = ActiveRecord::Base.connection.execute(grepDates).values
		
			for i in 0..(dates.length-1)
				if !dataTypeString.include? dates[i].to_s.gsub("[\"", "d").gsub("\"]", "").gsub("-", "_")
					dataTypeString = dataTypeString.to_s + ", " + dates[i].to_s.gsub("[\"", "d").gsub("\"]", "").gsub("-", "_") + " bigint"
					@datesForHTML.push(dates[i].to_s.gsub("[\"", "d").gsub("\"]", "").gsub("-", "_").to_s)
				end
			end
			
			# Fix cross tab that is not safe! --> second argument
			sqlFix = " ('"
			for i in 0..(dates.length-1)
				if !sqlFix.include? dates[i].to_s.gsub("[\"", "").gsub("\"]", "")
					if i == 0
						sqlFix = sqlFix.to_s + dates[i].to_s.gsub("[\"", "").gsub("\"]", "") + "'::date)"
					else
						sqlFix = sqlFix.to_s + ",('" + dates[i].to_s.gsub("[\"", "").gsub("\"]", "") + "') "
					end
				end
			end
			
			# Finish the pivotSql string
			pivotSql = "SELECT * FROM crosstab('SELECT * FROM prepivot', $$VALUES" + sqlFix + "$$) " + dataTypeString
			pivotSql = pivotSql + ")"
		end
		
		if params[:time] == "hour"				
			# GET ALL THE HOURS
			grepHours = "SELECT hours FROM prePivot"
			hours = ActiveRecord::Base.connection.execute(grepHours).values
			
			for i in 0..(hours.length-1)
				if !dataTypeString.include? hours[i].to_s.gsub("[\"", "d").gsub("\"]", "").gsub("-", "_").gsub(" ","_").gsub(":00:00","")
					dataTypeString = dataTypeString.to_s + ", " + hours[i].to_s.gsub("[\"", "d").gsub("\"]", "").gsub("-", "_").gsub(" ","_").gsub(":00:00","") + " bigint"
					@datesForHTML.push(hours[i].to_s.gsub("[\"", "d").gsub("\"]", "").gsub("-", "_").gsub(" "," h").gsub(":00:00","").to_s)
				end
			end
			
			# Fix cross tab that is not safe! --> second argument
			sqlFix = " ('"
			for i in 0..(hours.length-1)
				if !sqlFix.include? hours[i].to_s.gsub("[\"", "").gsub("\"]", "")
					if i == 0
						sqlFix = sqlFix.to_s + hours[i].to_s.gsub("[\"", "").gsub("\"]", "") + "'::timestamp)"
					else
						sqlFix = sqlFix.to_s + ",('" + hours[i].to_s.gsub("[\"", "").gsub("\"]", "") + "') "
					end
				end
			end
			
			# Finish the pivotSql string
			pivotSql = "SELECT * FROM crosstab('SELECT * FROM prepivot', $$VALUES" + sqlFix + "$$) " + dataTypeString
			pivotSql = pivotSql + ")"		
		end
		
		# Pivot the table
		@sql = sqlRecords
		@piv = pivotSql
		@results = ActiveRecord::Base.connection.execute(pivotSql).values
		
		# DROP TEMP PREPIVOT
		sqlDrop = "DROP TABLE prepivot"
		ActiveRecord::Base.connection.execute(sqlDrop).values
	end
	
	# Render the search results to the user
	render 'anal'
  end
  
  def show
	  # Check if the users typed anything in the search bar
	  if params[:search] != "" 
	  
		# Split the search string and remove ""
		values = params[:search].split("\" \"");
		values.each { |x| x.delete! '"'}
		
		# Set the logical parameters
		if params[:logic] == "and"
			logicParam = " AND "
			logicSign = " & "
		elsif params[:logic] == "or"
			logicParam = " OR "
			logicSign = " | "
		end
		
		# Add result text bolding 
		if params[:method]  == "exact" || params[:method]  == "dictionaries" || params[:method]  == "fuzzy"
			rankHeadlineString = "ts_headline('english', text, to_tsquery('"
			for i in 0..(values.length-1)
				if i != values.length-1
					rankHeadlineString = rankHeadlineString.to_s + "(" + values[i].to_s.gsub(" ", " & ") + ")" + logicSign.to_s
				else
					rankHeadlineString = rankHeadlineString.to_s + "(" + values[i].to_s.gsub(" ", " & ") + ")'))";
				end
			end
		end
		
		# Add result ranking
		if params[:method]  == "exact" || params[:method]  == "dictionaries" || params[:method]  == "fuzzy"
			rankHeadlineString = rankHeadlineString + ", ts_rank(texttsv, to_tsquery('"
			for i in 0..(values.length-1)
				if i != values.length-1
					rankHeadlineString = rankHeadlineString.to_s + "(" + values[i].to_s.gsub(" ", " & ") + ")" + logicSign.to_s
				else
					rankHeadlineString = rankHeadlineString.to_s + "(" + values[i].to_s.gsub(" ", " & ") + ")')) AS rank";
				end
			end
		end
		
		# Build the sql string core
		if params[:method]  == "exact"
			for i in 0..(values.length-1)
				if i != values.length-1
					sqlSubString = sqlSubString.to_s + " text LIKE '%" + values[i].to_s + "%'" + logicParam.to_s
				else
					sqlSubString = sqlSubString.to_s + " text LIKE '%" + values[i].to_s + "%'"
				end
			end
		elsif params[:method]  == "dictionaries"
			for i in 0..(values.length-1)
				if i != values.length-1
					sqlSubString = sqlSubString.to_s + " texttsv @@ to_tsquery('" + values[i].to_s.gsub(" ", " & ") + "')" + logicParam.to_s
				else
					sqlSubString = sqlSubString.to_s + " texttsv @@ to_tsquery('" + values[i].to_s.gsub(" ", " & ") + "')"
				end
			end
		elsif params[:method]  == "fuzzy"
			for i in 0..(values.length-1)
				if i != values.length-1
					sqlSubString = sqlSubString.to_s + "(" + values[i].to_s.gsub(" ", " & ") + ")" + logicSign.to_s
				else
					sqlSubString = sqlSubString.to_s + " text % '" + values[i].to_s + "'"
				end
			end
		end
		
		# Search with the constructed SQL string
		if params[:method]  == "exact" || params[:method]  == "dictionaries" || params[:method]  == "fuzzy"
			@sql = "SELECT text, " + rankHeadlineString + " FROM documents WHERE" + sqlSubString + " ORDER BY rank DESC"
			@documents = ActiveRecord::Base.connection.execute(@sql).values
		end
		
		# Before rendering the result, save the search query inside the DB
		for i in 0..(values.length-1)
			if i != values.length-1
				recordSave = recordSave.to_s + "'" + values[i].to_s.gsub(" ", " & ") + "'" + logicSign.to_s
			else
				recordSave = recordSave.to_s + "'" + values[i].to_s.gsub(" ", " & ") + "'";
			end
		end
		
		# Update/create the record inside the DB
		record = Record.create(search: recordSave.to_s, count: 1, time: DateTime.now)
	  end
	  
  # Render the search results to the user
  render 'home'
  end
end
