module ApplicationHelper
  
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "VocalVoters"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  # Returns estimate count 
  def estimate_count(query)
    if query.is_a?(Array)
      return query.length
    end    
    sql_array = ["SELECT planrows FROM estimate_row(?)", query.to_sql]
    sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, sql_array)
    begin
      ActiveRecord::Base.connection.execute(sanitized_query).values[0][0].to_f
    rescue
      return 0
    end
  end
  
end
