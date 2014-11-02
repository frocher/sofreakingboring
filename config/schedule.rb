
every 1.day, :at => '1:00 am' do
  runner "Project.snapshot"
end

every 1.day, :at => '4:30 am' do
  command "backup perform -t olb_backup"
end