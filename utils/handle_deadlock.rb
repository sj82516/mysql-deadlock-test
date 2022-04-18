def handle_deadlock
  result = ActiveRecord::Base.connection.execute("SHOW ENGINE INNODB STATUS").first[2]
  start_log = false
  result.split("\n").each_with_index do |s, i|
    start_log = true if (s == "LATEST DETECTED DEADLOCK")
    start_log = false if (s == "TRANSACTIONS")
    puts s if start_log
  end
end
