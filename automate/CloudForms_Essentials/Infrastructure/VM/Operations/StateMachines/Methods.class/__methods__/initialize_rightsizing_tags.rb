=begin
 initialize_rightsizing_tags.rb

 Author: Kevin Morey <kevin@redhat.com>

 Description: This method checks for the existence of the rightsize category and creates tags
-------------------------------------------------------------------------------
   Copyright 2016 Kevin Morey <kevin@redhat.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-------------------------------------------------------------------------------
=end
def log(level, msg, update_message = false)
  $evm.log(level, "#{msg}")
  @task.message = msg if @task && (update_message || level == 'error')
end

def process_tags(category, single_value, tag)
  # Convert to lower case and replace all non-word characters with underscores
  category_name = category.to_s.downcase.gsub(/\W/,'_')
  tag_name = tag.to_s.downcase.gsub(/\W/,'_')
  # if the category exists else create it
  unless $evm.execute('category_exists?', category_name)
    log(:info, "Creating Category: {#{category_name} => #{category}}")
    $evm.execute('category_create', :name => category_name,
                 :single_value => single_value, :description => "#{category}")
  end
  # if the tag exists else create it
  unless $evm.execute('tag_exists?', category_name, tag_name)
    log(:info, "Creating tag: {#{tag_name} => #{tag}}")
    $evm.execute('tag_create', category_name, :name => tag_name, :description => "#{tag}")
  end
end

begin

  category = 'rightsize'
  rightsize_tags = ['aggressive', 'moderate', 'conservative']
  rightsize_tags.each {|tag| process_tags( category, true, tag ) }

rescue => err
  log(:error, "[(#{err.class})#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
