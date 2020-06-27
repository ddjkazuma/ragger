class Dictionary < ActiveRecord::Base
  self.table_name = "dictionaries"
  
  def step_forward
    # status值初始为0，每复习成功一次，则+1，如果为3，则是复习成功了3次，将status的值改为-1，表示已经完成复习
    if status < 3
      increment! "status", 1
    else
      update_column "status", -1
    end
  end
  
end

