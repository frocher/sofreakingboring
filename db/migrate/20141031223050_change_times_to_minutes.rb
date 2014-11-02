class ChangeTimesToMinutes < ActiveRecord::Migration
  def change
    Task.update_all( 'original_estimate = original_estimate / 60, remaining_estimate = remaining_estimate / 60' )
    WorkLog.update_all( 'worked = worked / 60')
    ProjectSnapshot.update_all( 'original_estimate = original_estimate / 60, remaining_estimate = remaining_estimate / 60, work_logged = work_logged / 60' )
  end
end
