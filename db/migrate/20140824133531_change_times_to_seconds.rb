class ChangeTimesToSeconds < ActiveRecord::Migration
  def change
    Task.update_all( 'original_estimate = original_estimate * 3600, remaining_estimate = remaining_estimate * 3600' )
    WorkLog.update_all( 'worked = worked * 3600')
    ProjectSnapshot.update_all( 'original_estimate = original_estimate * 3600, remaining_estimate = remaining_estimate * 3600, work_logged = work_logged * 3600' )
  end
end
