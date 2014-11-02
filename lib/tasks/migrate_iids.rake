task migrate_iids: :environment do
  puts 'Tasks'
  Task.where(iid: nil).find_each(batch_size: 100) do |task|
    begin
      task.set_iid
      if task.update_attribute(:iid, task.iid)
        print '.'
      else
        print 'F'
      end
    rescue
      print 'F'
    end
  end

  puts 'done'
end